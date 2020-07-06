require 'setup/base'

module Setup::Log
   def warn message
      log(:warn, message)
   end

   def log kind, message
      $stderr.puts("[setup.rb][#{kind.upcase}] -> #{message}")
   end
end
