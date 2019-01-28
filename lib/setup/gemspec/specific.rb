module Setup::Gemspec::Specific
   RE = /\/psych.gemspec$/

   class << self
      def parse file
         spec = nil

         fix_preloaded_for(file)

         FileUtils.chdir(File.dirname(file)) { spec = Gem::Specification.load(File.basename(file)) }

         spec
      rescue Exception => e
         $stderr.puts "ERROR[#{e.class}]: #{e.message}"
      end

      def fix_preloaded_for file
         if Psych.constants.include?(:VERSION)
            Psych.send(:remove_const, :VERSION)
         end
      end
   end
end
