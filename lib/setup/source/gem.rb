require 'setup/source/base'

require 'tempfile'
require 'yaml'

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

   OPTIONS_IN = {
      spec: true,
   }

   attr_reader :spec

   class << self
      def spec_for options_in = {}
         spec_in = options_in[:spec]
         spec = spec_in.is_a?(String) && YAML.load(spec_in) || spec_in
         if options_in[:version_replaces] && version = options_in[:version_replaces][spec.name]
            spec.version = Gem::Version.new(version)
         end
         spec.require_paths = options_in[:srclibdirs] if options_in[:srclibdirs]

         spec
      end

      def name_for options_in = {}
         spec_for(options_in).name
      end

      def search dir, options_in = {}
         gemspecs = Setup::Gemspec.kinds.map { |const| Setup::Gemspec.const_get(const) }

         gemspec_files = Dir.glob("#{dir}/**/*", File::FNM_DOTMATCH).map do |f|
            gemspecs.map do |gemspec|
               gemspec::RE =~ f && [ gemspec, f ] || nil
            end
         end.flatten(1).compact.sort_by do |(gemspec, _)|
            gemspecs.index(gemspec)
         end

         specs = gemspec_files.map do |gemspec, f|
            new_if_valid(gemspec.parse(f), { root: File.dirname(f) }.merge(options_in))
         end.flatten(1).compact

         specs.map { |x| x.name }.uniq.map { |name| specs.find { |spec| spec.name == name } }
      end

      def new_if_valid spec, options_in = {}
         if spec && spec.platform == 'ruby'
            self.new(source_options({ spec: spec }.merge(options_in)))
         end
      end
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
      gemspec_file = Tempfile.new('gem.')
      gemspec_file.puts(dsl.to_ruby)
      gemspec_file.rewind
      gemspec_file.path
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
      @exttree ||= super { { '.' => spec.extensions.select { |file| /extconf\.rb$/ =~ file } } }
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
      super.merge(spec: spec.to_yaml)
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

   def description
      spec&.description
   end

   def license
      spec&.license
   end

   def url
      spec&.homepage
   end

   def summary
      !spec&.summary.empty? && spec&.summary 
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
   end
end
