require 'setup'

class Setup::Source
   attr_reader :rootdir

   autoload(:Fake, 'setup/source/fake')
   autoload(:Rakefile, 'setup/source/rakefile')
   autoload(:Gemfile, 'setup/source/gemfile')
   autoload(:Gem, 'setup/source/gem')

   TYPES = {
      rakefile: "Setup::Source::Rakefile",
      gemfile: "Setup::Source::Gemfile",
      gem: "Setup::Source::Gem",
      fake: "Setup::Source::Fake",
   }

   class << self
      def search_in dir, options = {}
         TYPES.map do |(name, const)|
            require("setup/source/#{name}")
            kls = self.const_get(const)
            kls.respond_to?(:search) && kls.search(dir, options) || []
         end.flatten.group_by do |source|
            source.rootdir
         end.map do |_, sources_in|
            gem_sources = sources_in.select { |source| source.is_a?(Setup::Source::Gem) }
            gem_sources.empty? && sources_in.first || gem_sources
         end.flatten
      end

      def load_from sources_in
         [ sources_in ].flatten.compact.map do |source_in|
            type_code_in = source_in["type"].to_s.to_sym
            type_code = TYPES.keys.include?(type_code_in) && type_code_in || :fake
            require("setup/source/#{type_code}")
            TYPES[type_code].constantize.new(source_in)
         end
      end
   end
end
