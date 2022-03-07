# Echoe based gemspec detection module
# Sample gems are: echoe
#
require 'setup/loader'

module Setup::Gemspec::Echoe
   extend ::Setup::Loader

   RE = /\/Rakefile$/i
   TYPE = 'Echoe'

   class << self
      def parse rakefile
         mm = app_file(rakefile)

         mm.objects.map {|o| o.spec }.uniq {|s| s.name }.first
      end
   end
end
