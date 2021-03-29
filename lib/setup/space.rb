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

   # +spec+ property returns the hash of the loaded spec if any
   #
   # sources #=> [...]
   attr_reader :spec

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
      @name ||= main_source&.name || spec && spec["name"]
   end

   # +name+ returns a default version for the space. Returns version of a source when
   # its root is the same as the space's root, and there is a explicitly main package.
   #
   # space.version # => 2.1.1
   #
   def version
      return @version if @version

      @version ||= main_source&.version || time_stamp
   end

   def main_source
      @main_source ||= sources.find { |source| source.rootdir == rootdir }
   end

   def time_stamp
      Time.now.strftime("%Y%m%d")
   end

   protected

   def initialize options: {}, space: {}
      @rootdir ||= options.delete(:rootdir)

      parse(space)
   end

   def parse space
      @rootdir ||= space.delete("rootdir")
      @spec ||= space.delete("spec")
      # binding.pry

      @sources ||= Setup::Source.load(space.delete("sources"))

      @space = space
   end

   def method_missing method, *args
      # binding.pry
      @space[method.to_s] || spec && spec[method.to_s] || super
   end
end

require 'setup/space/spec'
