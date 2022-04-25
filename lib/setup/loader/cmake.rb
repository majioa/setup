# Cmake based compilable gemspec detection, no gemspec is actually returned
# Sample gem is: hiredis
#
module Setup::Loader::Cmake
   def cmake file
      log = `cmake .`
      $stderr.puts(log)
   rescue Errno::ENOENT
      $stderr.puts "[setup.rb] -> Error: cmake is required to properly detect the gem"
   end
end
