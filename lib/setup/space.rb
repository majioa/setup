require 'yaml'

require 'setup/version'

class Setup::Space
   class InvalidSpaceFileError < StandardError; end

   @@space = {}

   # +rootdir+ property returns the root dir for the space
   #
   # rootdir #=> /root/dir/for/the/space
   #
   attr_reader :rootdir

   # +sources+ property returns the array of the sources (as hashes) found in
   # the space.
   #
   # sources #=> [...]
   attr_reader :sources

   class << self
      def load_from space_in
         space_h = case space_in
         when IO, StringIO
            YAML.load(space_in.readlines.join("\n"))
         when String
            raise InvalidSpaceFileError if !File.file?(space_in)

            YAML.load(IO.read(space_in))
         else
            raise InvalidSpaceFileError
         end

         @@space[space_in] = self.new(space: space_h)
      end

      def load
         load_from(Dir[".space"].first)
      end
   end

   # +name+ returns a default name of the space. Returns name of a source when
   # its root is the same as the space's root.
   #
   # space.name # => space-name
   #
   def name
      return @name if @name

      main_source = sources.find { |source| source.rootdir == rootdir }

      @name = main_source&.name
   end

   protected

   def initialize options: {}, space: nil
      @rootdir ||= options.delete(:rootdir)

      parse(space)
   end

   def parse space
      @rootdir ||= space.delete("rootdir")
      @sources ||= Setup::Source.load(space.delete("sources"))

      @space = space
   end

   def method_missing method, *args
      @space[method.to_s] || super
   end
end
