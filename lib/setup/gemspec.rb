module Setup::Gemspec
   autoload(:Specific, 'setup/gemspec/specific')
   autoload(:Hoe, 'setup/gemspec/hoe')
   autoload(:Olddoc, 'setup/gemspec/olddoc')
   autoload(:Cmake, 'setup/gemspec/cmake')
   autoload(:Gem, 'setup/gemspec/gem')

   class << self
      def kinds
         %i(Specific Hoe Olddoc Cmake Gem)
      end
   end
end
