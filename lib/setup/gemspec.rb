module Setup::Gemspec
   class << self
      def kinds
         %i(Specific Hoe Olddoc Cmake Gem)
      end
   end
end

require 'setup/gemspec/specific'
require 'setup/gemspec/hoe'
require 'setup/gemspec/olddoc'
require 'setup/gemspec/cmake'
require 'setup/gemspec/gem'
