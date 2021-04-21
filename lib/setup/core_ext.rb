#
# Ruby Extensions
#
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

  def ` cmd
    def lsfiles tokens
      mask = tokens.select { |t| t !~ /^-/ }.first&.sub('*', '**/*') || '**/*'
      list = Dir.glob(mask, File::FNM_DOTMATCH).select { |x| File.file?(x) }
      char = tokens.include?('-z') && "\0" || "\n"
      list.join(char)
    end

    tokens = cmd.split(/\s+/)

    res = __old_system_call(cmd)

    if res.empty? && tokens.first == 'git' && tokens[1] == 'ls-files'
      lsfiles(tokens)
    else
      res
    end
  rescue => e
    if tokens.first == 'git' && tokens[1] == 'ls-files'
       # TODO add gem TaskJuggler to test --
      i = tokens.index_of('--')
      if i
        lsfiles(tokens[i + 1..-1])
      else
        lsfiles(tokens[2..-1])
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
   }

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

class Array
   # actjoin(array) => [<pre_match1>, <pre_match2>, <pre_match3>, <post_match>]; array = [match1, match2, match3]
   #
   def actjoin array
      self.map.with_index { |x, i| [ x, array[i] ].compact }.flatten.join
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

class Hash
   def deep_merge other
      return self if other.nil? or other == {}

      other_hash = other.is_a?(Hash) && other || { nil => other }
      common_keys = self.keys & other_hash.keys
      base_hash = (other_hash.keys - common_keys).reduce({}) do |res, key|
         res[key] = other_hash[key]
         res
      end

      self.reduce(base_hash) do |res, (key, value)|
         new =
         if common_keys.include?(key)
            case value
            when Hash, OpenStruct
               value.deep_merge(other_hash[key])
            when Array
               value.concat([ other_hash[key] ].compact.flatten(1))
            when NilClass
               other_hash[key]
            else
               [ value, other_hash[key] ].compact.flatten(1)
            end
         else
            value
         end

         res[key] = new
         res
      end
   end
end

class Object
   def blank?
      self.nil? || self.to_s == ""
   end

   def to_os
      OpenStruct.new(self.to_h.map {|(x, y)| [x.to_s, y] }.to_h)
   end
end

class OpenStruct
   def merge_to other
      OpenStruct.new(other.to_h.merge(self.to_h))
   end

   def merge other
      OpenStruct.new(self.to_h.merge(other.to_h))
   end

   def map *args, &block
      res = self.class.new

      self.each_pair do |key, value|
         res[key] = block[key, value]
      end

      res
   end

   def select &block
      res = self.class.new

      self.each_pair do |key, value|
         res[key] = value if block[key, value]
      end

      res
   end

   def compact
      select { |_, value| value.present? }
   end

   def each *args, &block
      self.each_pair(*args, &block)
   end

   def reduce default = nil, &block
      res = default

      self.each_pair do |key, value|
         res = block[res, key, value]
      end

      res
   end

   def deep_merge other_in
      return self if other_in.nil? or other_in.blank?

      other =
         if other_in.is_a?(OpenStruct)
            other_in.dup
         elsif other_in.is_a?(Hash)
            other_in.to_os
         else
            OpenStruct.new(nil => other_in)
         end

      self.reduce(other) do |res, key, value|
         res[key] =
            if res.table.keys.include?(key)
               case value
               when Hash, OpenStruct
                  value.deep_merge(res[key])
               when Array
                  value.concat([ res[key] ].compact.flatten(1))
               when NilClass
                  res[key]
               else
                  [ value, res[key] ].compact.flatten(1)
               end
            else
               value
            end

         res
      end
   end
end
