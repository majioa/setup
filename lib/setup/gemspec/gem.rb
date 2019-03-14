module Setup::Gemspec::Gem
   RE = /\.gemspec$/

   class << self
      def parse file
         spec = nil

         FileUtils.chdir(File.dirname(file)) { spec = Gem::Specification.load(File.basename(file)) }

         spec
      rescue Exception => e
         $stderr.puts "ERROR[#{e.class}]: #{e.message}"
      end
   end
end
