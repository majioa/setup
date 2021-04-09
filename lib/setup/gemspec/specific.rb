module Setup::Gemspec::Specific
   RE = /\/psych.gemspec$/

   class << self
      def parse file
         spec = nil

         fix_preloaded_for(file)

         spec = FileUtils.chdir(File.dirname(file)) { Gem::Specification.load(File.basename(file)) }

         spec
      rescue Exception => e
         $stderr.puts "WARN [#{e.class}]: #{e.message}"
      end

      def fix_preloaded_for file
         if Psych.constants.include?(:VERSION)
            $".grep(/#{File.dirname(file)}/).each { |f| $".delete(f) }
            Psych.send(:remove_const, :VERSION)
         end
      end
   end
end
