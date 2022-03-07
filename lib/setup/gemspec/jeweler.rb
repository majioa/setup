# jeweler tasks based gemspec detection module
# example: "polyglot" gem
#
require 'setup/loader'

module Setup::Gemspec::Jeweler
   extend ::Setup::Loader

   RE = /\/Rakefile$/i
   TYPE = 'Jeweler::Tasks'

   class << self
      def parse rakefile
         mm = app_file(rakefile)

         mm.objects.map {|o| o.spec }.first
      end
   end
end
