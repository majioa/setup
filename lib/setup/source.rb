require 'setup'

class Setup::Source
   attr_reader :rootdir

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
            self.new(source_in: source_in)
         end
      end
   end

   def initialize source_in: {}
      parse(source_in)
   end

   def parse source_in
      @rootdir ||= source_in.delete("rootdir")
   end

   # +name+ returns name of the source by default it is the name of the current folder,
   # if it is the root folder the name is "root".
   # A mixin can redefine the method to return the proper value
   #
   # source.name #=> "source_name"
   #
   def name
      @rootdir.split("/").last || "root"
   end
end

require 'setup/source/gem'
require 'setup/source/rakefile'
require 'setup/source/gemfile'
