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

      binding.pry
      @name = sources.find { |source| source[:root] == rootdir }
   end

   # +sources+ property returns the array of the sources (as hashes) found in
   # the space.
   #
   # sources #=> [...]
   def sources
      space["project"][:sources]
   end

   protected

   def initialize options: {}, space: nil
      @rootdir ||= options.delete(:rootdir)

      parse(space)
   end

   def parse space
      @rootdir ||= space.delete("rootdir")
   end

   #def method_missing method, *args
   #   binding.pry
   #   self[method.to_s] || super
   #end
end
