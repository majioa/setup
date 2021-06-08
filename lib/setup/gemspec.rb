module Setup::Gemspec
   AUTOMAP = {
      Specific: "setup/gemspec/specific",
      Index: "setup/gemspec/index",
      Bones: "setup/gemspec/bones",
      Echoe: "setup/gemspec/echoe",
      Rookbook: "setup/gemspec/rookbook",
      Hoe: "setup/gemspec/hoe",
      Olddoc: "setup/gemspec/olddoc",
      Cmake: "setup/gemspec/cmake",
      Mast: "setup/gemspec/mast",
      Gem: "setup/gemspec/gem",
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
