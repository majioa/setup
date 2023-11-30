require 'bundler/shared_helpers'
require 'bundler/runtime'

require 'setup'
require 'setup/log'

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
    include Setup::Log
    
       STATES = {
          invalid: ->(_, source) { !source.valid? },
          disabled: ->(space, source) { space.is_disabled?(source) },
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
    def initialize config, options = {}
      # pre-init require
      $:.unshift(Dir.pwd)

      self.stat_sources = options.delete(:sources_hash)
      @rootdir  = options.delete(:rootdir)
      @config   = config
      @options  = options

      @name     = root_source&.name
      @version  = root_source&.version
      @loadpath = ['lib']

        show_tree if Setup::Log.ios[:info]

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
       info("Source list are the following:")
       stat_sources.each do |(source, status)|
          path = File.join(source.root, File.basename(source.source_file))
          info_in = "#{STATUS_CHARS[status]} #{TYPE_CHARS[source.type.to_sym]}#{[source.name, source.version].compact.join(":")} [#{path}]"
          info(info_in)
       end
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
          sources_hash: stat_sources.map {|(x, y)| [x.to_h, y] },
          options: options,
          rootdir: rootdir
       }
    end

    def spec_version
       config.gem_version_replace.first.last
    end

      # returns all the sources with their statuses, and sorted by their root value
      #
      #def stat_sources
      def stat_sources &block
         return @stat_sources if @stat_sources

         @stat_sources = Setup::Source.search(rootdir, options).group_by do |x|
               [x.name, x.version].compact.join(":")
            end.map do |(full_name, v)|
               sorten =
                  v.sort do |x,y|
                     c0 = Setup::Source::KINDS.index(x.class.to_s.to_sym) <=> Setup::Source::KINDS.index(y.class.to_s.to_sym)
                     c1 = c0 == 0 && y.version <=> x.version || c0
                     c2 = c1 == 0 && x.name <=> y.name || c1
                     c3 = c2 == 0 && y.source_names.grep(/gemspec/).count <=> x.source_names.grep(/gemspec/).count

                     c2 == 0 && c3 == 0 && x.root.size <=> y.root.size || c3 != 0 && c3 || c2
                  end.map.with_index do |source, index|
                     [source, source_status(source)]
                  end
   
               if primary = sorten.find { |(_, x)| x == :valid  }
                  sorten = sorten.map do |(x, status)|
                     if x != primary.first && status == :valid &&
                        x.alias_to(primary.first)

                        [x, :duplicated]
                     else
                        [x, status]
                     end
                  end
               end

               sorten
            end.flatten(1).sort_by {|(x, _)| x.root.size }.each do |(source, status)|
               block[source, status] if block_given?
            end
      end

      # returns status for the source for the project
      #
      def source_status source
         %i(valid disabled invalid).reduce() do |res, status|
            STATES[status][self, source] && status || res
         end
      end

    # Sets a source list from config
    #
    def stat_sources= value
       @stat_sources = value&.map do |(source_in, source_status)|
          source_in[:alias_names] = source_in[:alias_names] | (config&.aliases || [])
          source =
             case source_in.delete(:type)
             when 'rakefile'
                new_source(Setup::Source::Rakefile, source_in)
             when 'gemfile'
                new_source(Setup::Source::Gemfile, source_in)
             when 'gem'
                new_source(Setup::Source::Gem, source_in)
             end

          [source, source_status]
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
         stat_sources.any? {|(source, _)| source.is_a?(Setup::Source::Gem) }
      end

    def is_disabled? source
      config.ignore_path_tokens.map do |t|
         t.is_a?(Regexp) && %r{/[^/]*#{t}[^/]*/} || %r{/#{t}/}
      end.any? do |t|
         t =~ source.source_file
      end || config.ignore_names.any? { |i| i === source.name }
    end
      #
      #
      def compilable?
         stat_sources.any? { |(source, _)| source.compilable? }
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
       source_names = valid_sources.map(&:name)

       valid_sources.each do |source|
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
                  Setup::Target::Gem.new(source: source, options: options.merge(config.to_h))
               when Setup::Source::Gemfile
                  Setup::Target::Site.new(source: source, options: options.merge(config.to_h))
               when Setup::Source::Rakefile
                  Setup::Target::Site.new(source: source, options: options.merge(config.to_h))
               end
            end)
      end
  end
end
