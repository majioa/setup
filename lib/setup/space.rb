require 'yaml'

require 'setup/version'

class Setup::Space
   class InvalidSpaceFileError < StandardError; end

   TYPES = {
      sources: Setup::Source
   }

   @@space = {}

   # +spec+ property returns the hash of the loaded spec if any, it can be freely
   # reassigned.
   #
   # spec #=> {...}
   #
   attr_accessor :spec

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

   # +rootdir+ returns the root dir for the space got from the options.
   #
   # rootdir #=> /root/dir/for/the/space
   #
   def rootdir
      @rootdir ||= options.rootdir || '/'
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

   # +dependencies+ returns main source dependencies list as an array of Gem::Dependency
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
      @sources ||= Setup::Source.search_in(rootdir || Dir.pwd, options)
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
      @ignored_names ||= (options.ignored_names || []) - regarded_names
   end

   def regarded_names
      @regarded_names ||= options.regarded_names || []
   end

   def spec_type
      @spec_type ||= options.spec_type
   end

   protected

   def initialize space: nil, options: nil, spec: nil
      @options = options || {}.to_os
      parse(space || {}.to_os)

      if @spec ||= spec
         @spec.space = self
      elsif spec
         spec_model = Setup::Spec.find(self.spec_type)
         @spec = spec_model.new(options: spec, space: self)
      elsif options.spec_file
         @spec = Setup::Spec.load_from(IO.read(options.spec_file))
         @spec.space = self
      end
   end

   def parse space_in
      space_in.each do |name, value_in|
         value = case value_in
            when Array
               #value_in.map {|x| YAML.load(x) }
               value_in
            when Hash
               value_in.to_os
            when String
               YAML.load(value_in)
            else
               value_in
            end

         instance_variable_set(:"@#{name}", value)
      end
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
      def load_from! space_in: Dir[".space"].first, options: nil
         space = case space_in
         when IO, StringIO
            YAML.load(space_in.readlines.join(""))
         when String
            raise InvalidSpaceFileError.new(space_in: space_in) if !File.file?(space_in)

            YAML.load(IO.read(space_in))
         when NilClass
         else
            raise InvalidSpaceFileError
         end.to_os

         @@space[space.name] = self.new(space: space, options: options || {}.to_os)
      end

      def load_from space_in: Dir[".space"].first, options: nil
         load_from!(space_in: space_in, options: options)
      rescue InvalidSpaceFileError
         @@space[nil] = new(options: options)
      end
   end
end

require 'setup/space/spec'
