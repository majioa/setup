require 'setup'

module Setup::Source
   class << self
      def search dir, options = {}
         %i(Gem Gemfile Rakefile).map do |const|
            self.const_get(const).search(dir, options)
         end.flatten.group_by do |source|
            source.root
         end.map do |_, sources_in|
            gem_sources = sources_in.select { |source| source.is_a?(Setup::Source::Gem) }
            gem_sources.empty? && sources_in.first || gem_sources
         end.flatten
      end
   end
end

require 'setup/source/gem'
require 'setup/source/rakefile'
require 'setup/source/gemfile'
