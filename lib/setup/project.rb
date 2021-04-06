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
     attr_reader :config, :version_replaces

    #
    def initialize options = {}
      self.sources  = options.delete(:sources)
      @rootdir  = options.delete(:rootdir)
      @config   = options.delete(:config) || raise
      @options  = options

      @name     = root_source&.name
      @version  = root_source&.version
      @loadpath = ['lib']

      all_sources.each do |source|
         info = "#{source.type} '#{source.name}' at #{source.root}"
         $stderr.puts source.valid? && is_enabled?(source) && info || "[ #{info} ]"
      end


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
    end

    # The name of the package, used to install docs in system doc/ruby-{name}/ location.
    attr :name

    # Current version number of project.
    attr :version

    #
    attr :loadpath

    alias load_path loadpath

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

    # Returns all the source list
    #
    def all_sources
       @all_sources ||= Setup::Source.search(rootdir, options)
    end

    # Returns the valid source list
    #
    def sources
       @sources ||= all_sources.select do |source|
          source.valid? && is_enabled?(source)
       end
    end

    # Sets a source list from config
    #
    def sources= value
       @sources = value&.map do |source_in|
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
      @root_source ||= sources.find { |source| rootdir == source.root }
    end

    def has_gem?
      sources.any? {|source| source.is_a?(Setup::Source::Gem) }
    end

    def is_enabled? source
      !config.ignore_names.include?(source.name)
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
            sources.map do |source|
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
