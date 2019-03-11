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
     attr_reader :options

    # Match used to determine the root dir of a project.
     ROOT_MARKER = '{.index,setup.rb,.setup,lib/,app/,Gemfile,*.gemspec}'

    #
    def initialize options = {}
      self.sources  = options.delete(:sources)
      @rootdir  = options.delete(:rootdir)
      @options  = options

      @dotindex_file = find('.index')

      @dotindex = YAML.load_file(@dotindex_file) if @dotindex_file

      @name     = root_source.name
      @version  = root_source.version
      @loadpath = ['lib']


      if @dotindex
        @name     = @dotindex['name']
        @version  = @dotindex['version']
        @loadpath = (@dotindex['paths'] || {})['load']
      else
        if file = find('.setup/name')
          @name = File.read(file).strip
        end
        if file = find('.setup/version')
          @version = File.read(file).strip
        end
        if file = find('.setup/loadpath')
          @loadpath = File.read(file).strip
        end
      end
    end

    attr :dotindex

    # The name of the package, used to install docs in system doc/ruby-{name}/ location.
    attr :name

    # Current version number of project.
    attr :version

    #
    attr :loadpath

    alias load_path loadpath

    # Locate project root.
    def rootdir
      @rootdir ||= (
        root = Dir.glob(File.join(Dir.pwd, ROOT_MARKER), File::FNM_CASEFOLD).first
        if !root
          raise Error, "not a project directory"
        else
          Dir.pwd
        end
      )
    end

    def to_h
       {
          sources: sources.map {|x| x.to_h },
          options: options,
          rootdir: rootdir
       }
    end

    # Returns a source list
    #
    def sources
       @sources ||= Setup::Source.search(rootdir, options)
    end

    # Sets a source list from config
    #
    def sources= value
       @sources = value&.map do |source_in|
          case source_in.delete(:type)
          when 'root'
             Setup::Source::Root.new(source_in)
          when 'gem'
             Setup::Source::Gem.new(source_in)
          end
       end
    end

    # Returns a root source
    #
    def root_source
      @root_source ||= sources.find { |source| source.is_a?(Setup::Source::Root) }
    end

    def has_gem?
      sources.any? {|source| source.is_a?(Setup::Source::Gem) }
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

  end

end
