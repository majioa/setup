module Setup::Gemspec::Specific
   RE = /\/(?<name>psych|rdoc|signet|coderay).gemspec$/

   RULE = {
      RDoc: "rdoc",
      Signet: "signet",
      Psych: "psych",
      CodeRay: "coderay",
      Daemons: "daemons"
   }

   class << self
      def parse file
         spec = nil

         ENV["RELEASE"] = "1"
         dir = File.dirname(file)
         libdir = File.join(dir, 'lib')
         $:.unshift(libdir) if !$:.include?(libdir)

         match = file.match(RE)
         rule = RULE.find { |(cls, _)| cls.to_s.downcase == match[:name] }

         fix_preloaded_for(rule[0], rule[1], dir)

         FileUtils.chdir(dir) { spec = Gem::Specification.load(File.basename(file)) }

         spec
      rescue Exception => e
         $stderr.puts "WARN [#{e.class}]: #{e.message}"
      end

      def fix_preloaded_for const_name, name, dir
         if Object.constants.include?(const_name)
            Object.send(:remove_const, const_name)
            to_remove = $LOADED_FEATURES.select {|x| /#{name}/ =~ x }
            $LOADED_FEATURES.replace($LOADED_FEATURES - to_remove)

            require(name)
         end
      end
   end
end
