# Cmake based compilable gemspec detection, no gemspec is actually returned
# Sample gem is: hiredis
#
module Setup::Gemspec::Cmake
   RE = /\/(cmake|CMakeLists.txt)$/

   class << self
      attr_reader :hoe

      def parse _
         log = `cmake .`
         $stderr.puts(log)
         nil
      rescue Errno::ENOENT
         $stderr.puts "[setup.rb] -> Error: cmake is required to properly detect the gem"
      end
   end
end
