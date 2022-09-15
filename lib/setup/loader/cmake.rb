# Cmake based compilable gemspec detection, no gemspec is actually returned
# Sample gem is: hiredis
#
module Setup::Loader::Cmake
   def cmake file
      log_in = `cmake .`
      debug(log_in)
   rescue Errno::ENOENT
      error "Error: cmake is required to properly detect the gem"
   end
end
