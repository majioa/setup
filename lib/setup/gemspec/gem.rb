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

      def fix_preloaded spec, gemspec, file
         if spec.name == 'psych' && Psych.constants.include?(:VERSION)
            Psych.send(:remove_const, :VERSION)
            gemspec.parse(file)
         else
            spec
         end
      end
   end
end
