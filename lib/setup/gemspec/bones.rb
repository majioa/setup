# Bones based gemspec detection module
# Sample gems are: bones, loquacious, little-plugger
#
require 'setup/loader'

module Setup::Gemspec::Bones
   extend ::Setup::Loader

   RE = /\/Rakefile$/i

   class << self
      def parse rakefile
         mm = app_file(rakefile) do |_|
            ::Bones.config.gem._spec.version && ::Bones.config.gem._spec
         end

         mm.objects.first
      rescue NameError
         nil
      end
   end
end
