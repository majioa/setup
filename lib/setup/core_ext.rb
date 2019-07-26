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

  def ` cmd
    tokens = cmd.split(/\s+/)

    res = __old_system_call(cmd)

    if res.empty? && tokens.first == 'git' && tokens[1] == 'ls-files'
      mask = tokens[2..-1].select { |t| t !~ /^-/ }.first&.sub('*', '**/*') || '**/*'
      list = Dir.glob(mask, File::FNM_DOTMATCH).select { |x| File.file?(x) }
      char = tokens.include?('-z') && "\0" || "\n"
      list.join(char)
    else
      res
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

class Dir
   class << self
      alias :__glob :glob

      def glob pattern_in, flags = 0, options = {}
         if (flags & File::FNM_EXTGLOB) > 0
            re = /!\((.*)\)/
            tokens, matches = pattern_in.actsplit(re)
            matches_re = matches.map { |x| "^(?!.*#{x.match(re)[1].gsub('|*/', '').gsub('\\\\','\\')})" }
            tokens_re = tokens.map { |x| x.gsub(/\*+/, '.*').gsub(/\//, '\/?') }
            match_re = tokens_re.actjoin(matches_re)

            list = __glob(tokens.join('**'), flags, options).select do |file|
               file =~ /#{match_re}/
            end

            if base = options[:base]
               list.select { |r| r[0...base.size] == base }
            else
               list
            end
         else
            __glob(pattern_in, flags, options)
         end
      end
   end
end
