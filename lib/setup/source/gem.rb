require 'bundler/dependency'
require 'tempfile'
require 'yaml'

require 'setup/source/base'

class Setup::Source::Gem < Setup::Source::Base
   BIN_IGNORES = %w(test)
   OPTION_KEYS = %i(root spec version replace_list aliases)

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

   INC_FILTER  = ->(s, f, dir) { s.spec.files.include?(File.join(dir, f)) }

   OPTIONS_IN = {
      spec: true,
   }

   class << self
      def load spec_in
         if Gem::Version.new(Psych::VERSION) >= Gem::Version.new("4.0.0")
            YAML.load(spec_in, aliases: true, permitted_classes: [Gem::Specification, Gem::Version, Gem::Dependency, Gem::Requirement, Symbol, OpenStruct])
         else
            YAML.load(spec_in)
         end
      end

      def spec_for options_in = {}
         spec_in = options_in[:spec]
         spec = spec_in.is_a?(String) && load(spec_in) || spec_in
         version =
            if options_in[:version_replaces] && options_in[:version_replaces][spec.name]
               options_in[:version_replaces][spec.name]
            elsif !options_in[:gem_version_replace].empty?
               prever = options_in[:gem_version_replace].find {|(n,v)| n == spec.name }&.last
               /([=><]+\s*)?(?<version>.*)/ =~ prever
               version
            end

         if version
            spec.version = Gem::Version.new(version)
         end

         spec.require_paths = options_in[:srclibdirs] if options_in[:srclibdirs]

         spec
      end

      def name_for options_in = {}
         spec_for(options_in).name
      end

      def search dir, options_in = {}
         specs = Dir.glob("#{dir}/**/*", File::FNM_DOTMATCH).map do |f|
            Setup::Gemspec.gemspecs.map do |gemspec|
               gemspec::RE =~ f && [ gemspec, f ] || nil
            end
         end.flatten(1).compact.sort_by do |(gemspec, _)|
            Setup::Gemspec.gemspecs.index(gemspec)
         end.map do |gemspec, f|
            new_if_valid(gemspec.parse(f), { root: File.dirname(f) }.merge(options_in))
         end.flatten(1).compact

         specs.map { |x| x.name }.uniq.map do |name|
            specs.sort_by { |s| s.version }.select { |spec| spec.name == name }.last
         end
      end

      def new_if_valid spec, options_in = {}
         if spec && spec.platform == 'ruby' && spec.version
            self.new(source_options({ spec: spec }.merge(options_in)))
         end
      end
   end

   def gemfile
      @gemfile ||= Setup::Source::Gemfile.new(
         root: options[:root],
         gem_version_replace: options[:gem_version_replace],
         gem_skip_list: dsl.deps.map(&:name),
         gem_append_list: [ self.dep ])
   end

   def dep
      Bundler::Dependency.new(name, Gem::Requirement.new(["~> #{version}"]), options: { type: :runtime })
   end

   def fullname
      [ name, version ].compact.join('-')
   end

   def name
      spec && spec.name
   end

   def version
      spec && spec.version.to_s
   end

   def gemspec_path
      gemspec_file = Tempfile.create('gem.')
      gemspec_file.puts(dsl.to_ruby)
      gemspec_file.rewind
      gemspec_file.path
   end

   def gemfile_path
      if gemfile.dsl.valid?
         gemfile_file = Tempfile.create('Gemfile.')
         gemfile_file.puts(gemfile.dsl.to_gemfile)
         gemfile_file.rewind
         gemfile_file.path
      end
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
      @exetree ||= super { Dir.chdir(root) do
            exedirs.map { |dir| [ dir, Dir.chdir(File.join(root, dir)) { Dir.glob("{#{spec.executables.join(',')}}") } ] }.to_h
         end }
   end

   def docsrctree
      @docsrctree ||= super { { '.' => spec.extra_rdoc_files } }
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
      extfiles.any?
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

   def spec
      @spec ||= self.class.spec_for(options)
   end

   def rake
      @rake ||= Setup::Rake.new(File.join(options[:root]))
   end

   protected

   def extroots
      @extroots ||= extfiles.map { |extfile| File.dirname(extfile) }
   end

   def exedir
      @exedir ||= if_exist('exe')
   end

   def initialize options_in = {}
      super

      gemfile
   end
end
