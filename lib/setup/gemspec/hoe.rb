# Hoe based gemspec detection module
# Sample gems are: hoe, racc, nokogiri
#
require 'setup/loader'

module Setup::Gemspec::Hoe
   extend ::Setup::Loader

   RE = /\/Rakefile$/i
   TYPE = 'Hoe'

   class << self
      def parse rakefile
         mm = app_file(rakefile)

         mm.objects.map {|o| o.spec }.first
      end
   end
end
