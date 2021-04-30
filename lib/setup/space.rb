require 'yaml'

require 'setup/version'

class Setup::Space
   class InvalidSpaceFileError < StandardError; end

   TYPES = {
      sources: Setup::Source
   }

   @@space = {}
   @@options = {}

   # +options+ property returns the hash of the loaded options if any
   #
   # options #=> {...}
   #
   attr_reader :options

   # +name+ returns a default name of the space with a prefix if any. It returns name of a source when
   # its root is the same as the space's root, or returns name defined in the spec if any.
   # If no spec defined returns name of last folder in rootdir or "root" as a default main source name.
   #
   # space.name # => space-name
   #
   def name
      return @name if @name

      @name = main_source&.name || spec&.name
   end

   # +version+ returns a default version for the space. Returns version of a source when
   # its root is the same as the space's root, or returns version defined in the spec if any,
   # or returns default one, which is the datestamp.
   #
   # space.version # => 2.1.1
   #
   def version
      return @version if @version

      @version ||= main_source&.version || spec&.version || time_stamp
   end

   attr_writer :rootdir

   # +rootdir+ returns the root dir for the space got from the options,
   # defaulting to the current folder.
   #
   # rootdir #=> /root/dir/for/the/space
   #
   def rootdir
      @rootdir ||= read_attribute(:rootdir) || Dir.pwd
   end

   def main_source
      @main_source ||= valid_sources.find { |source| source.rootdir == rootdir }
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
      @changes ||= spec&.changes || main_source&.respond_to?(:changes) && main_source.changes || []
   end

   # +summaries+ returns an open-struct formatted summaries with locales as keys
   # in the space or spec defined if any, otherwise returns blank open struct.
   #
   # space.summaries # => #<OpenStruct en_US.UTF-8: ...>
   #
   def summaries
      return @summaries if @summaries

      if summaries = spec&.summaries
         summaries
      elsif summary = main_source&.summary
         { "" => summary }.to_os
      end
   end

   # +licenses+ returns license list defined in all the valid sources found in the space.
   #
   # space.licenses => # ["MIT"]
   #
   def licenses
      return @licenses if @licenses

      licenses = valid_sources.map { |source| source.licenses rescue [] }.flatten.uniq

      @licenses = !licenses.blank? && licenses || spec&.licenses || []
   end

   # +dependencies+ returns all the valid source dependencies list as an array of Gem::Dependency
   # objects, otherwise returning blank array.
   def dependencies
      @dependencies ||= valid_sources.map do |source|
         source.respond_to?(:dependencies) && source.dependencies || []
      end.flatten.reject do |dep|
         sources.any? do |s|
            dep.name == s.name &&
            dep.requirement.satisfied_by?(Gem::Version.new(s.version))
         end
      end
   end

   def files
      @files ||= valid_sources.map { |s| s.files rescue [] }.flatten.uniq
   end

   def executables
      @executables ||= valid_sources.map { |s| s.executables rescue [] }.flatten.uniq
   end

   def docs
      @docs ||= valid_sources.map { |s| s.docs rescue [] }.flatten.uniq
   end

   def compilables
      @compilables ||= valid_sources.map { |s| s.extensions rescue [] }.flatten.uniq
   end

   # +sources+ returns all the sources in the space. It will load from the space sources,
   # or by default will search sources in the provided folder or the current one.
   #
   # space.sources => # [#<Setup::Source:...>, #<...>]
   #
   def sources
      @sources ||= read_attribute(:sources) || Setup::Source.search_in(rootdir, options)
   end

   # +valid_sources+ returns all the valid sources based on the current source list.
   #
   # space.valid_sources => # [#<Setup::Source:...>, #<...>]
   #
   def valid_sources
      @valid_sources ||= sources.select do |source|
         source.valid? && is_regarded?(source)
      end
   end

   def is_regarded? source
      !ignored_names.include?(source.name)
   end

   def ignored_names
      @ignored_names ||= (read_attribute(:ignored_names) || []) - regarded_names
   end

   def regarded_names
      @regarded_names ||= read_attribute(:regarded_names) || []
   end

   def spec_type
      @spec_type ||= read_attribute(:spec_type) || spec && spec.class.to_s.split("::").last.downcase
   end

   def read_attribute attr
      options.send(attr) || state.send(attr)
   end

   def options_for type
      @@options[type] = type::OPTIONS.map do |option|
         value = self.options[option] || self.respond_to?(option) && self.send(option) || nil

         [ option, value ]
      end.compact.to_os
   end

   # +spec+ property returns the hash of the loaded spec if any, it can be freely
   # reassigned.
   #
   # spec #=> {...}
   #
   def spec
      @spec ||= _spec
   end

   def spec= value
      _spec(value)
   end

   protected

   def _spec spec_in = nil
      _spec = spec_in || state.spec

      @spec =
         if _spec.is_a?(Setup::Spec::Rpm)
            _spec
         elsif _spec.is_a?(String)
            YAML.load(_spec)
         elsif spec_type
            Setup::Spec.find(spec_type).new
         elsif options.spec_file
            Setup::Spec.load_from(IO.read(options.spec_file))
         end

      if @spec
         @spec.options = options_for(@spec.class)
      end

      @spec
   end

   def initialize state_in = {}, options = {}
      @options = (options || {}).to_os
      @state = (state_in || {}).to_os
   end

   def context
      @context ||= options[:context] || spec&.context || {}
   end

   def method_missing method, *args
      value =
         instance_variable_get(:"@#{method}") ||
         (spec.send(method) rescue nil) ||
         options[method] ||
         spec&.options[method.to_s] ||

      instance_variable_set(:"@#{method}", value || super)
   end

   class << self
      def load_from! state_in = Dir[".space"].first, options = {}
         state = case state_in
         when IO, StringIO
            YAML.load(state_in.readlines.join(""))
         when String
            raise InvalidSpaceFileError.new(state_in: state_in) if !File.file?(state_in)

            YAML.load(IO.read(state_in))
         when NilClass
         else
            raise InvalidSpaceFileError
         end.to_os

         @@space[state.name] = self.new(state, options)
      end

      def load_from state_in = Dir[".space"].first, options = {}
         load_from!(state_in, options)
      rescue InvalidSpaceFileError
         @@space[nil] = new(nil, options)
      end
   end
end

require 'setup/space/spec'
