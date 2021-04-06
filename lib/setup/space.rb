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
            YAML.load(space_in.readlines.join(""))
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

   # +name+ returns a default name of the space with a prefix if any. It returns name of a source when
   # its root is the same as the space's root, or returns name defined in the spec if any.
   #
   # space.name # => space-name
   #
   def name
      return @name if @name

      @name = main_source&.name || spec && spec["name"]
   end

   # +name+ returns a default version for the space. Returns version of a source when
   # its root is the same as the space's root, or returns version defined in the spec if any,
   # or returns default one, which is the datestamp.
   #
   # space.version # => 2.1.1
   #
   def version
      return @version if @version

      @version ||= main_source&.version || spec && spec["version"] || time_stamp
   end

   def main_source
      @main_source ||= sources.find { |source| source.rootdir == rootdir }
   end

   def time_stamp
      Time.now.strftime("%Y%m%d")
   end

   # +changes+ returns a list of open-struct formatted changes in the space or
   # spec defined if any, otherwise returns blank array.
   #
   # space.changes # => []
   #
   def changes
      return @changes if @changes

      changes = main_source&.respond_to?(:changes) && main_source.changes || nil
      @changes = spec && spec["changes"] || changes || []
   end

   # +summaries+ returns a list of open-struct formatted summaries in the space or
   # spec defined if any, otherwise returns blank array.
   #
   # space.summaries # => []
   #
   def summaries
      @summaries ||= spec && spec["summaries"] || OpenStruct.new("" => main_source&.summary)
   end

   # +licenses+ returns license list defined in all the sources found in the space.
   #
   # space.licenses => # ["MIT"]
   #
   def licenses
      return @licenses if @licenses

      licenses = sources.map(&:licenses).flatten.uniq
      @licenese = !licenses.blank? && licenses || spec && spec["licenses"] || nil
   end

   # +dependencies+ returns main source dependencies list as an array of Gem::Dependency
   # objects, otherwise returning blank array.
   def dependencies
      @dependencies ||= sources.map(&:dependencies).flatten.reject do |dep|
         sources.any? do |s|
            dep.name == s.name &&
            dep.requirement.satisfied_by?(Gem::Version.new(s.version))
         end
      end
   end

   def files
      # binding.pry
      @files ||= sources.map { |s| s.files rescue [] }.flatten.uniq
   end

   def executables
      @executables ||= sources.map { |s| s.executables rescue [] }.flatten.uniq
   end

   def docs
      @docs ||= sources.map { |s| s.docs rescue [] }.flatten.uniq
   end

   def compilables
      @compilables ||= sources.map { |s| s.extensions rescue [] }.flatten.uniq
   end

   protected

   def initialize options: {}, space: {}, spec: nil
      @rootdir ||= options.delete(:rootdir)
      if @spec ||= spec
         @spec.space = self
      elsif space["spec"]
         spec_model = Setup::Spec.find(space["spec_type"])
         @spec = spec_model.new(options: space["spec"], space: self)
      end

      parse(space)
   end

   def parse space
      @rootdir ||= space.delete("rootdir")
      # binding.pry

      @sources ||= Setup::Source.load(space.delete("sources"))

      @space = space
   end

   def method_missing method, *args
      # binding.pry
      @space[method.to_s] || spec && spec.respond_to?(method) && spec.send(method) || super
   end
end

require 'setup/space/spec'
