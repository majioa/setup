# Gem::PackageTask based gemspec detection module
# Sample is: ruby-gnome2
#
require 'setup/loader'

module Setup::Gemspec::PackageTask
   extend ::Setup::Loader

   RE = /\/Rakefile$/i
   TYPE = 'Gem::PackageTask'

   class << self
      def parse rakefile
         mm = app_file(rakefile)

         mm.objects.map {|o| o.gem_spec }.uniq { |s| s.name }.first
      end
   end
end
