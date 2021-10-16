module Setup::Gemspec

   AUTOMAP = {
      Specific: "setup/gemspec/specific",
      Bones: "setup/gemspec/bones",
      Echoe: "setup/gemspec/echoe",
      Rookbook: "setup/gemspec/rookbook",
      Pom: "setup/gemspec/pom",
      Hoe: "setup/gemspec/hoe",
      Olddoc: "setup/gemspec/olddoc",
      Cmake: "setup/gemspec/cmake",
      Mast: "setup/gemspec/mast",
      Jeweler: "setup/gemspec/jeweler",
      Gem: "setup/gemspec/gem",
      Rakefile: "setup/gemspec/rakefile",
      PackageTask: "setup/gemspec/package_task",
   }

   class << self
      def kinds
         AUTOMAP.keys
      end

      def gemspecs
         @gemspecs ||= kinds.map do |const|
            require(AUTOMAP[const])
            const_get(const)
         end
      end
   end
end
