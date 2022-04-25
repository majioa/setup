require 'bundler/shared_helpers'
require 'bundler/runtime'

require 'setup'

module Setup

  # The Project class encapsulates information about the project/package
  # setup is handling.
  #
  # Setup.rb can use information about your project to provide additional
  # features.
  #
  # To inform Setup.rb of the project's name, version and load path
  # you can create a file in you project's root directory called `.index`.
  # This is a YAML file with minimum entries of:
  #
  #     ---
  #     name: foo
  #     version: 1.0.0
  #     paths:
  #       load: [lib]
  #
  # See [Indexer](http://github.com/rubyworks/indexer) for more information about
  # this file and how to easily maintain it.
  #
  # If a `.index` file is not found Setup.rb will look for `.setup/name`,
  # `.setup/version` and `.setup/loadpath` files for this information.
  #
  # As of v5.1.0, Setup.rb no longer recognizes the VERSION file
  #
  class Project
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

     attr_reader :config, :version_replaces

    #
    def initialize options = {}
      self.all_sources  = options.delete(:sources)
      @rootdir  = options.delete(:rootdir)
      @config   = options.delete(:config) || raise
      @options  = options

      @name     = root_source&.name
      @version  = root_source&.version
      @loadpath = ['lib']

        show_tree

        if file = find('.setup/name')
          @name = File.read(file).strip
        end
        if file = find('.setup/version')
          @version = File.read(file).strip
        end
        if file = find('.setup/loadpath')
          @loadpath = File.read(file).strip
        end

        # post create hook
        autoalias
        runtime
    end

    def show_tree
       log("Source list are the following:")
       stat_source_tree.each do |(path, stated_sources)|
          stated_sources.each do |(source, status)|
          info = "#{STATUS_CHARS[status]} #{TYPE_CHARS[source.type.to_sym]}#{[source.name, source.version].compact.join(":")} [#{path}]"
             log(info)
          end
       end
    end

    def log text
       $stderr.puts text
    end

    # The name of the package, used to install docs in system doc/ruby-{name}/ location.
    attr :name

    # Current version number of project.
    attr :version

    #
    attr :loadpath

    alias load_path loadpath

    def runtime
       @runtime ||= root_source && Bundler.instance_variable_set(:@setup, Bundler::Runtime.new(rootdir, root_source.dsl.definition))
    end

    # Locate project root.
    def rootdir
      @rootdir ||= Dir.pwd
    end

    def to_h
       {
          sources: sources.map {|x| x.to_h },
          options: options,
          rootdir: rootdir
       }
    end

    def spec_version
       config.gem_version_replace.first.last
    end

    # Returns list of all the sources
    #
    def sources
       @sources ||= Setup::Source.search(rootdir, options)
    end

    # returns all the sources with their statuses, and sorted by a its root value
    #
    def stat_sources &block
       @stat_sources =
          sources.group_by { |x| x.name }.map do |(name, v)|
             v.sort do |x,y|
                c0 = Setup::Source::KINDS.index(x.class.to_s.to_sym) <=> Setup::Source::KINDS.index(y.class.to_s.to_sym)
                c1 = c0 == 0 && y.version <=> x.version || c0

                c1 == 0 && x.root.size <=> y.root.size || c1
             end.map.with_index do |source, index|
                [source, source_status(source, index > 0)]
             end
          end.flatten(1).sort_by {|(x, _)| x.root.size }.each do |(source, status)|
             block[source, status] if block_given?
          end
    end

    # Sets a source list from config
    #
    def all_sources= value
       @sources = value&.map do |source_in|
          source_in[:aliases] = source_in[:aliases] | (config&.aliases || [])
          case source_in.delete(:type)
          when 'rakefile'
             new_source(Setup::Source::Rakefile, source_in)
          when 'gemfile'
             new_source(Setup::Source::Gemfile, source_in)
          when 'gem'
             new_source(Setup::Source::Gem, source_in)
          end
       end
    end

    # returns source tree, and sorted, and then grouped by a its root value
    #
    def stat_source_tree
      @stat_source_tree ||=
         stat_sources.group_by {|(x, _)| x.root }.map do |(path, sources)|
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

    # returns the valid sources for the project
    #
    def valid_sources
       @valid_sources = stat_sources.map {|(source, status)| status == :valid && source || nil }.compact
    end

    # options for the object
    #
    def new_source type, object_options_in
       # TODO enable back options_for
       type.new(type.source_options(object_options_in))
    end

    # options for the object
    #
#    def options_for type, object_options_in
#       option_keys = type.const_get(:OPTION_KEYS) || []
#       options_in = config.to_h.map { |(key, value)| [ key.to_sym, value ] }.to_h.merge(object_options_in)
#       option_keys.map { |key| [ key, options_in[ key ]] }.to_h
#    end

    # Returns a root source
    #
    def root_source
       @root_source ||= valid_sources.find { |source| rootdir == source.root }
    end

    def has_gem?
      sources.any? {|source| source.is_a?(Setup::Source::Gem) }
    end

    def is_disabled? source
      config.ignore_names.any? { |i| i === source.name }
    end
    #
    #
    def compilable?
      sources.any? { |source| source.compilable? }
    end

    #
    def yardopts
      Dir.glob(File.join(rootdir, '.yardopts')).first
    end

    #
    def document
      Dir.glob(File.join(rootdir, '.document')).first
    end

    # Find a file relative to project's root directory.
    def find(glob, flags=0)
      case flags
      when :casefold
        flags = File::FNM_CASEFOLD
      else
        flags = flags.to_i
      end
      Dir.glob(File.join(rootdir, glob), flags).first
    end

    def chroot
       File.expand_path(config.install_prefix)
    end

    def options
       @options.merge(chroot: chroot)
    end

    def autoalias
       source_names = sources.map(&:name)

       sources.each do |source|
          config.current_source_name = source.name

          name = source.name.gsub(/[_\-\.]+/, '-')
          if name != source.name
             config.current_alias = name
          end

          # autoaliasing binaries to the source name but when no other source name matches to a binfile
          config.current_alias = source.exefiles - (source.exefiles & source_names)
       end

       # turn current source name to common
       config.current_source_name = nil
    end

      def select_source name
         ObjectSpace.each_object(Setup::Source::Base).select { |x| x.name == name }
      end

   # +targets+ returns an install target list for the sources
   #
   # space.targets #=> [ <#Setup::Target::Gem...>, ... ]
   #
   # TODO move to target actor
      def targets
         @targets ||= (
            valid_sources.map do |source|
               case source
               when Setup::Source::Gem
                  Setup::Target::Gem.new(source: source, options: options)
               when Setup::Source::Gemfile
                  Setup::Target::Site.new(source: source, options: options)
               when Setup::Source::Rakefile
                  Setup::Target::Site.new(source: source, options: options)
               end
            end)
      end
  end
end
