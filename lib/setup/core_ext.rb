#=th
# Ruby Extensions
#
require 'bundler'

Encoding.default_external = Encoding::UTF_8

# Is this needed any more?
class << File #:nodoc: all

  unless File.respond_to?(:read)   # Ruby 1.6 and less

    def read(fname, options = {})
      open(fname){ |f| return f.read }
    end

  end

  # for corrupted Window's stat(2)
  def dir?(path)
    directory?((path[-1,1] == '/') ? path : path + '/')
  end

end

unless Errno.const_defined?(:ENOTEMPTY)   # Windows?

  module Errno  #:nodoc:
    class ENOTEMPTY  #:nodoc:
      # We do not raise this exception, implementation is not needed.
    end
  end

end

module Kernel
   alias :__old_system_call :`
   alias :__setup_orig_require :require
   alias :__setup_orig_gem :gem

  def ` cmd
    def lsfiles tokens
      masks = tokens.select do |t|
        t !~ /^-/
      end.map do |x|
        x =~ /\*/ && x.sub('*', '**/*') || File.directory?(x) && "#{x}/**/*" || File.file?(x) && x || '**/*'
      end
      masks << "**/*" if masks.empty?
      list = masks.map {|mask| Dir.glob(mask, File::FNM_DOTMATCH).select { |x| File.file?(x) } }.flatten
      char = tokens.include?('-z') && "\0" || "\n"
      list.join(char)
    end

    tokens = cmd.split(/\s+/)

    res = __old_system_call(cmd)

    if res.empty? && tokens.first == 'git' && tokens.include?('ls-files')
      i = tokens.index('ls-files')
      lsfiles(tokens[i + 1..-1])
    else
      res
    end
  rescue => e
    if tokens.first == 'git'
      if tokens.include?('ls-files')
       # TODO add gem TaskJuggler to test --
        i = tokens.index('--')
        if i
          lsfiles(tokens[i + 1..-1])
        else
          lsfiles(tokens[2..-1])
        end
      elsif tokens.include?('describe')
        if tokens.include?("--tags")
          ObjectSpace.each_object(Setup::Project).first.spec_version
        else
          res
        end
      else
        res
      end
    else
      raise(e)
    end
  end

   MODULES = {
      'olddoc' => 'setup/extcore/olddoc',
      'wrongdoc' => 'setup/extcore/wrongdoc',
      'bones' => 'setup/extcore/bones',
      'echoe' => 'setup/extcore/echoe',
      'jeweler' => 'setup/extcore/jeweler',
   }

   def config
      @@config ||= ObjectSpace.each_object(Setup::Configuration).first
   rescue NameError
   end

   def gem(gem_name, *requirements) # :doc
      if req_in = config && config.use_gem_dependencies[gem_name]
         req = Gem::Requirement.new(req_in)
         requirements = requirements.map {|r| Gem::Requirement.new(r).merge(req).to_s.split(",") }.flatten
      end

      __setup_orig_gem(gem_name, *requirements)
   rescue Gem::MissingSpecError => e
      !MODULES[gem_name.to_s] && raise(e) || false
   end

   def require mod
      __setup_orig_require(mod)
   rescue LoadError => e
      if MODULES[mod]
         __setup_orig_require(MODULES[mod])
      else
         raise e
      end
   end
end

module Bundler
   class Runtime
      alias :__setup :setup

      def setup(*groups)
         /(bundler\/setup.rb|Gemfile|Rakefile):/ !~ caller[0] && super || self
      end
   end

   class << self
      def read_file(file)
         SharedHelpers.filesystem_access(file, :read) do
            begin
               File.open(file, "r:UTF-8", &:read)
            rescue Errno::ENOENT
               ""
            end
         end
      end
   end
end

class Array
   # actjoin(array) => [<pre_match1>, <pre_match2>, <pre_match3>, <post_match>]; array = [match1, match2, match3]
   #
   def actjoin array
      self.map.with_index { |x, i| [ x, array[i] ].compact }.flatten.join
   end
end

class Pathname
   def === value
      if value.is_a?(String)
         self.to_s === value
      else
         super
      end
   end

   def == value
      if value.is_a?(String)
         self.to_s == value
      else
         super
      end
   end
end

class String
   # actsplit(string, re) => [<pre_match1>, <pre_match2>, <pre_match3>, <post_match>], [match1, match2, match3]
   #
   def actsplit re
      string = self
      res = []

      until string.empty? do
         if m = re.match(string)
            res << [ string[ 0...m.begin(0) ], m[0] ]
            string = string[ m.end(0)..-1 ]

            if string.empty?
               res << [ string, nil ]
            end
         else
            res << [ string, nil ]
            string = ''
         end
      end

      res.transpose.map { |x| x.compact }
   end

   PLURAL_R = {
      /([xcs])$/ => '\1es',
      /us$/ => 'i',
      /$/ => 's'
   }

   SINGLE_R = {
      /([xcs])es$/ => '\1',
      /i$/ => 'us',
      /s$/ => ''
   }

   def make_plural
      PLURAL_R.reduce(nil) do |res, (re, char)|
         res || self.dup.sub!(re, char)
      end.to_s
   end

   def make_singular
      SINGLE_R.reduce(nil) do |res, (re, char)|
         res || self.dup.sub!(re, char)
      end.to_s
   end
end

class Symbol
   def make_plural
      to_s.make_plural.to_sym
   end

   def make_singular
      to_s.make_singular.to_sym
   end
end

class Object
   def self.const_get c
      super
   rescue Exception => e
      begin
        require c.to_s.downcase
      rescue Exception => e
      end

      super
   end
end

class Gem::Requirement
   MERGE_RELAS = { #:nodoc:
      "="  =>  :first,
      "!=" =>  :dup,
      ">"  =>  :max,
      "<"  =>  :min,
      ">=" =>  :max,
      "<=" =>  :min,
      "~>" =>  lambda do |a|
         ranges = a.map { |v| [v, v.bump] }.transpose
         ranges[0]&.max...ranges[1]&.min
      end
   }.freeze

   OR_RELAS = { #:nodoc:
      "="  =>  :min,
      "!=" =>  :dup,
      ">"  =>  :min,
      "<"  =>  :max,
      ">=" =>  :min,
      "<=" =>  :max,
      "~>" =>  lambda do |a|
         ranges = a.map { |v| [v, v.bump] }.transpose
         ranges[0]&.min...ranges[1]&.max
      end
   }.freeze

   def | other_requirement
      reqs_tmp = self.requirements | other_requirement.requirements

      relas =
         Gem::Requirement::OR_RELAS.map do |(op, prc)|
            selected = reqs_tmp.map { |(rel, version)| rel == op && version || nil }.compact

            prc.is_a?(Proc) && prc[selected] || selected.send(prc)
         end

      b = [ relas[0], relas[2], relas[4], relas[6].begin ].compact.min
      e = [ relas[3], relas[5], relas[6].end ].compact.max

      more = ![2,4,6].all? {|x| relas[x] === nil }
      less = ![3,5,6].all? {|x| relas[x] === nil }
      bounds =
         [ b && Gem::Requirement.new("#{more && ">" || ""}#{b != relas[2] && "=" || ""} #{b}") || nil,
           e && Gem::Requirement.new("#{less && "<" || ""}#{e != relas[3] && "=" || ""} #{e}") || nil ].compact

      nes = relas[1].select {|ver| bounds.all? {|b| b.satisfied_by?(ver) }}

      reqs = bounds | nes

      Gem::Requirement.new(reqs)
   end

   def merge other_requirement
      reqs_tmp = self.requirements | other_requirement.requirements

      relas =
         Gem::Requirement::MERGE_RELAS.map do |(op, prc)|
            selected = reqs_tmp.map { |(rel, version)| rel == op && version || nil }.compact

            prc.is_a?(Proc) && prc[selected] || selected.send(prc)
         end

      reqs =
         if relas[0]
            [ relas[0] ]
         else
            e = [ relas[3], relas[5], relas[6].begin ].compact.max
            b = [ relas[2], relas[4], relas[6].end ].compact.min

            bounds =
               [ b && Gem::Requirement.new(">#{b != relas[2] && "=" || ""} #{b}") || nil,
                 e && Gem::Requirement.new("<#{e != relas[3] && "=" || ""} #{e}") || nil ].compact

            nes = relas[1].select {|ver| bounds.all? {|b| b.satisfied_by?(ver) }}

            bounds | nes
         end

      Gem::Requirement.new(reqs)
   end
end
