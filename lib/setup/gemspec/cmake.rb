module Setup::Gemspec::Cmake
   RE = /\/(cmake|CMakeLists.txt)$/

   class << self
      attr_reader :hoe

      def parse rakefile
         log = `cmake`
      rescue Errno::ENOENT
      end
   end
end
