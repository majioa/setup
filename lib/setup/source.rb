require 'setup'

class Setup::Source
   attr_reader :rootdir

   Types = {
      rakefile: "Setup::Source::Rakefile",
      gemfile: "Setup::Source::Gemfile",
      gem: "Setup::Source::Gem",
   }

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

      def load sources_in
         [ sources_in ].flatten.compact.map do |source_in|
            type_code = source_in["type"]
            type = type_code && Types[type_code.to_sym] || "Setup::Source::Base"
            type.constantize.new(source_in)
          end
      end
   end
end

require 'setup/source/gem'
require 'setup/source/rakefile'
require 'setup/source/gemfile'
