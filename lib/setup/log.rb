require 'setup/base'

module Setup::Log
   def warn message
      log(message, :warn)
   end

   def log message, kind = :info
      $stderr.puts("[setup.rb][#{kind.upcase}] -> #{message}")
   end
end
