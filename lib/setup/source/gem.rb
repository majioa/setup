require 'tempfile'
require 'yaml'
require 'date'

class Setup::Source::Gem < Setup::Source::Base
   BIN_IGNORES = %w(test)
   OPTION_KEYS = %i(rootdir spec version replace_list aliases)

   EXE_DIRS = ->(s) { s.spec.bindir || s.exedir || nil }
   EXT_DIRS = ->(s) do
      s.spec.extensions.select do |file|
         /extconf\.rb$/ =~ file
      end.map do |file|
         File.dirname(file)
      end.uniq
   end
   LIB_DIRS = ->(s) { s.require_pure_paths }
   DOCSRC_DIRS = ->(s) { s.require_pure_paths }

   OPTIONS_IN = {
      spec: true,
   }

   attr_reader :gem_version_replace

   class << self
      def spec_for options_in = {}
         spec_in = options_in["spec"]
         spec = spec_in.is_a?(String) && YAML.load(spec_in) || spec_in
         if options_in["version-replaces"] && version = options_in["version-replaces"][spec.name]
            spec.version = Gem::Version.new(version)
         end
         spec.require_paths = options_in["source-lib-folders"] if options_in["source-lib-folders"]

         spec
      end

      def name_for options_in = {}
         spec_for(options_in).name
      end

      def search dir, options_in = {}
         sources = Dir.glob("#{dir}/**/*", File::FNM_DOTMATCH).map do |f|
            Setup::Gemspec.gemspecs.map do |gemspec|
               gemspec::RE =~ f && [ gemspec, f ] || nil
            end
         end.flatten(1).compact.sort_by do |(gemspec, _)|
            Setup::Gemspec.gemspecs.index(gemspec)
         end.map do |gemspec, f|
            new_if_valid(gemspec.parse(f), options_in.merge(rootdir: File.dirname(f)))
         end.flatten(1).compact

         sources.map { |x| x.name }.uniq.map do |name|
           # Sort by firstly version, the newer is moved forward,
           # then rootdir size, the closer to root folder is moved forward
           # then keep found order
           sources.select { |s| s.name == name }.sort do |x, y|
             r = y.version <=> x.version
             r == 0 &&
               (x.rootdir.size > y.rootdir.size && -1 ||
                x.rootdir.size < y.rootdir.size && 1) || r
           end.first
         end
      end

      def new_if_valid spec, options_in = {}
         if spec && spec.platform == 'ruby'
            self.new(source_options(options_in.merge(spec: spec)))
         end
      end
   end

   def gemfile
      @gemfile ||= Setup::Source::Gemfile.new({
         rootdir: rootdir,
         gem_version_replace: gem_version_replace,
         gem_skip_list: dsl.deps.map(&:name),
         gem_append_list: [ self.dep ]}.to_os)
   end

   def dep
      Gem::Dependency.new(name, Gem::Requirement.new(["~> #{version}"]), :runtime)
   end

   def fullname
      [ name, version ].compact.join('-')
   end

   def spec
      return @spec if @spec.is_a?(Gem::Specification)

      @spec =
         if @spec.is_a?(String)
            YAML.load(@spec)
         else
            Gem::Specification.new
         end
   end

   def name
      spec.name
   end

   def version
      spec.version.to_s
   end

   def gemspec_path
      gemspec_file = Tempfile.new('gem.')
      gemspec_file.puts(dsl.to_ruby)
      gemspec_file.rewind
      gemspec_file.path
   end

   def gemfile_path
      if gemfile.dsl.valid?
         gemfile_file = Tempfile.new('Gemfile.')
         gemfile_file.puts(gemfile.dsl.to_gemfile)
         gemfile_file.rewind
         gemfile_file.path
      end
   end

   def dsl
      @dsl ||= Setup::DSL.new(source: self, replace_list: replace_list)
   end

   # tree

   def datatree
      # TODO deep_merge
      @datatree ||= super { { '.' => spec.files } }
   end

   def exttree
      @exttree ||= super
   end

   def exetree
      @exetree ||= super { Dir.chdir(rootdir) do
            exedirs.map { |dir| [ dir, Dir.chdir(File.join(rootdir, dir)) { Dir.glob("{#{spec.executables.join(',')}}") } ] }.to_h
         end }
   end

   def docsrctree
      @docsrctree ||= super { { '.' => spec.extra_rdoc_files } }
   end

   def docs
      # TODO make docs to docdir with lib/.rb replace to .ri
      #require 'pry';binding.pry
      (!spec.rdoc_options.blank? && [ default_ridir ] || files(:lib)) | spec.extra_rdoc_files
   end

   # custom

   def extroot_for file
      extroots.find { |extroot| extroot == file[0...extroot.size] }
   end

   # Queries

   # +valid?+ returns state of validity of the gem: true or false
   # Returns true when name of the gem is set.
   #
   def valid?
      !name.nil?
   end

   def compilable?
      compilables.any?
   end

   def compilables
      extfiles | spec.extensions
   end

   def to_h
      # TODO !ruby/array:Files strangely appeared during building the securecompare gem, what leads to exceptions on load
      super.merge(spec: spec.to_yaml.gsub(/!ruby\/array:Files/, ""))
   end

   def required_ruby_version
      spec&.required_ruby_version || super
   end

   def required_rubygems_version
      spec&.required_rubygems_version || super
   end

   def deps groups = nil
      spec&.dependencies&.select { |dep| !groups || [ groups ].flatten.include?(dep.type) }
   end

   def require_pure_paths
      @require_pure_paths ||= (
         paths = spec.require_paths.select { |path| path !~ /^\// }
         paths.any? && paths || ['lib'])
   end

   # Default group
   def group
      "Development/Ruby"
   end

   def descriptions
      OpenStruct.new(Setup::I18n.default_locale => spec.description)
   end

   # Default prefix "gem" for gem names
   def name_prefix
      "gem"
   end

   def uri
      spec.homepage
   end

   def vcs
      spec.metadata&.[]("source_code_uri")
   end

   def dependencies type = nil
      spec.dependencies.select { |dep| !type || dep.type == type }
   end

   def provide
      Gem::Dependency.new(spec.name, Gem::Requirement.new(["= #{spec.version}"]), :runtime)
   end

   def licenses
      spec.licenses
   end

   protected

   def extroots
      @extroots ||= extfiles.map { |extfile| File.dirname(extfile) }
   end

   def exedir
      @exedir ||= if_exist('exe')
   end

   #
   def initialize options_in = {}
      super

      @spec = self.class.spec_for(options_in)

      gemfile
   end

   def method_missing name, *args
      spec.respond_to?(name) && spec.send(name, *args) || super
   end
end
