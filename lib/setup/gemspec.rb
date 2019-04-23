module Setup::Gemspec
   class << self
      def kinds
         %i(Specific Rakefile Olddoc Cmake Gem)
      end
   end
end

require 'setup/gemspec/specific'
require 'setup/gemspec/rakefile'
require 'setup/gemspec/olddoc'
require 'setup/gemspec/cmake'
require 'setup/gemspec/gem'
