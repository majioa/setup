module Setup::Gemspec::Specific
   RE = /\/(?<name>psych|rdoc|signet).gemspec$/

   RULE = {
      RDoc: "lib/rdoc",
      Signet: "lib/signet",
      Psych: "lib/psych"
   }

   class << self
      def parse file
         spec = nil

         match = file.match(RE)
         rule = RULE.find { |(cls, _)| cls.to_s.downcase == match[:name] }

         fix_preloaded_for(rule[0], rule[1], file)

         FileUtils.chdir(File.dirname(file)) { spec = Gem::Specification.load(File.basename(file)) }

         spec
      rescue Exception => e
         $stderr.puts "WARN [#{e.class}]: #{e.message}"
      end

      def fix_preloaded_for const_name, lib, file
         core_file = File.join(File.dirname(file), lib + '.rb')
         if Object.constants.include?(const_name)
            if File.file?(core_file)
               Object.send(:remove_const, const_name)
               require_relative(core_file)
            end
         end

         version_file = File.join(File.dirname(file), File.join(lib, "version.rb"))
         const = Object.const_get(const_name)
         if const.constants.include?(:VERSION)
            if File.file?(version_file)
               const.send(:remove_const, :VERSION)
               require_relative(version_file)
            end
         end
      end
   end
end
