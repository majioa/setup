# gemspec detection module in a pure rakefile
# no example
#
require 'setup/loader'

module Setup::Gemspec::Rakefile
   extend ::Setup::Loader

   RE = /\/Rakefile$/i
   TYPE = 'Gem::Specification'

   class << self
      def parse rakefile
         mm = app_file(rakefile)

         mm.objects.map {|o| o.spec }.uniq { |s| s.name }.first
      end
   end
end
