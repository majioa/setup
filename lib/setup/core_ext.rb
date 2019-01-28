#
# Ruby Extensions
#

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

    $stderr.puts '----'
    $stderr.puts tokens
    $stderr.puts '===='

    res = __old_system_call(cmd)

    if tokens.first == 'git' && tokens[1] == 'ls-files' && res.empty?
      mask = tokens[2..-1].select { |t| t !~ /^-/ }.first&.sub('*', '**/*') || '**/*'
      list = Dir.glob(mask, File::FNM_DOTMATCH).select { |x| File.file?(x) }
      char = tokens.include?('-z') && "\0" || "\n"
      list.join(char)
    else
      res
    end
  end
end
