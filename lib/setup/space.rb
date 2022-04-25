require 'rubygems'

require 'setup/version'
require 'setup/log'

class Setup::Space
   include Setup::Log

   class InvalidSpaceFileError < StandardError; end

   TYPES = {
      sources: Setup::Source
   }

   STATES = {
      invalid: ->(_, source, _) { !source.valid? },
      disabled: ->(space, source, _) { space.is_disabled?(source) },
      duplicated: ->(_, _, dup) { dup },
   }

   TYPE_CHARS = {
      gem: '*',
      gemfile: '&',
      rakefile: '^',
   }

   STATUS_CHARS = {
      invalid: 'X',
      disabled: '-',
      duplicated: '=',
      valid: 'V',
   }


   Gem.load_yaml

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
   # or returns default one.
   #
   # space.version # => 2.1.1
   #
   def version
      return @version if @version

      @version ||= main_source&.version || spec&.version
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
      return @main_source if @main_source

      reals = valid_sources.select { |source| !source.is_a?(Setup::Source::Fake) }
      if spec && !spec.state.blank?
         specen_source = reals.find { |real| spec.state["name"] === real.name }
      end

      root_source ||= valid_sources.find { |source| source.rootdir == rootdir }
      @main_source =
         specen_source || root_source.is_a?(Setup::Source::Fake) && reals.size == 1 && reals.first || root_source
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
      regarded_names.any? {|i| i === source.name } ||
         !ignored_names.any? {|i| i === source.name } &&
         !ignored_path_tokens.any? {|t| /\/#{t}\// =~ source.source_file }
   end

   def ignored_names
      @ignored_names ||= (read_attribute(:ignored_names) || [])
   end

   def regarded_names
      @regarded_names ||= read_attribute(:regarded_names) || []
   end

   def ignored_path_tokens
      @ignored_path_tokens ||= (read_attribute(:ignored_path_tokens) || [])
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
      @spec ||= gen_spec
   end

   def spec= value
      gen_spec(value)
   end

   def is_disabled? source
      options.ignored_path_tokens.any? { |t| /\/#{t}\// =~ source.source_file } ||
         options.ignored_names.any? { |i| i === source.name }
   end

   protected

   def gen_spec spec_in = nil
      spec_pre = spec_in || state.spec

      @spec =
         if spec_pre.is_a?(Setup::Spec::Rpm)
            spec_pre
         elsif spec_pre.is_a?(String)
            YAML.load(spec_pre)
         elsif options&.spec_file
            Setup::Spec.load_from(IO.read(options.spec_file))
         elsif @spec_type || options&.spec_typae
            Setup::Spec.find(@spec_type || options.spec_type).new
         end

      if @spec
         @spec.options = options_for(@spec.class)
      end

      @spec
   end

   def initialize state_in = {}, options = {}
      @options = (options || {}).to_os
      @state = (state_in || {}).to_os

      show_tree
   end

   def show_tree
      log("Sources:")
      stat_source_tree.each do |(path_in, stated_sources)|
         stated_sources.each do |(source, status)|
            path = File.join(path_in, File.basename(source.source_file)) if source.source_file
            stat = [STATUS_CHARS[status], TYPE_CHARS[source.type.to_sym]].join(" ")
            namever = [source.name, source.version].compact.join(":")
            info = "#{stat}#{namever} [#{path}]"

            log(info)
         end
      end
   end

   # returns all the sources with their statuses, and sorted by a its rootdir value
   #
   def stat_sources &block
      @stat_sources =
         sources.group_by { |x| x.name }.map do |(name, v)|
            # aliasing
            v.each {|x| x.alias_to(v) }

            # statusing
            v.sort do |x,y|
               c0 = Setup::Source::TYPES.keys.index(x.class.to_s.to_sym) <=> Setup::Source::TYPES.keys.index(y.class.to_s.to_sym)
               c1 = c0 == 0 && y.version <=> x.version || c0

               c1 == 0 && x.rootdir.size <=> y.rootdir.size || c1
            end.map.with_index do |source, index|
               [source, source_status(source, index > 0)]
            end
         end.flatten(1).sort_by {|(x, _)| x.rootdir.size }.each do |(source, status)|
            block[source, status] if block_given?
         end
   end

   # returns source tree, and sorted, and then grouped by a its rootdir value
   #
   def stat_source_tree
      @stat_source_tree ||=
         stat_sources.group_by {|(x, _)| x.rootdir }.map do |(path, sources)|
            [File.join('.', path[rootdir.size..-1]), sources]
         end.to_h
   end

   # returns status for the source for the project
   #
   def source_status source, dup
      %i(valid duplicated disabled invalid).reduce() do |res, status|
         STATES[status][self, source, dup] && status || res
      end
   end

   def context
      @context ||= options[:context] || spec&.context || {}
   end

   def method_missing method, *args
      value =
         instance_variable_get(:"@#{method}") ||
         (spec.send(method) rescue nil) ||
         options&.[](method) ||
         spec&.options&.[](method.to_s) ||

      instance_variable_set(:"@#{method}", value || super)
   end

   class << self
      def load_from! state_in = Dir[".space"].first, options = {}
         system_path_check # TODO required to generate spec rubocop

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

      def system_path_check
         # fix paths
         paths = ObjectSpace.each_object(Gem::Specification).map do |s|
            path = s.full_gem_path rescue nil

            s.require_paths.map do |x|
               File.absolute_path?(x) && x || path && File.join(path, x) || nil
            end
         end.flatten.compact

         $:.unshift(*paths) # $.replace(paths | $:)
      end
   end
end

require 'setup/space/spec'
