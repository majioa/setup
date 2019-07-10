module Setup::Gemspec
   class << self
      def kinds
         %i(Specific Rakefile Rookbook Hoe Olddoc Cmake Gem)
      end
   end
end

require 'setup/gemspec/specific'
require 'setup/gemspec/rookbook'
require 'setup/gemspec/hoe'
require 'setup/gemspec/rakefile'
require 'setup/gemspec/olddoc'
require 'setup/gemspec/cmake'
require 'setup/gemspec/gem'
