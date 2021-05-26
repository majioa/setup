require 'setup'

module ::Setup::Source
   attr_reader :rootdir

   TYPES =
      %w(Gem Gemfile Rakefile Fake Base).reduce({}) do |types, name|
         autoload(:"#{name}", File.dirname(__FILE__) + "/source/#{name.downcase}")
         types.merge(name.downcase.to_sym => "Setup::Source::#{name}")
      end

   class << self
      def search_in dir, options = {}
         sources_pre =
            TYPES.map do |(name, const)|
               kls = self.const_get(const)
               kls.respond_to?(:search) && kls.search(dir, options) || []
            end.flatten | [ self::Fake.new({ rootdir: dir }.to_os) ]

         sources_pre.group_by do |source|
            source.rootdir
         end.map do |_a, sources_in|
            #gem_sources = sources_in.select { |source| source.is_a?(Setup::Source::Gem) }
            #gem_sources.empty? && sources_in.first || gem_sources
            sources_pre = sources_in.sort_by do |source_in|
               TYPES.values.index(source_in.class.to_s)
            end

            sources_pre.select {|source_pre| source_pre.class == sources_pre.first.class }
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
