require 'bundler/dependency'
require 'tempfile'
require 'date'

require 'setup/source/base'
require 'setup/log'
require 'setup/loader'
require 'setup/loader/yaml'
require 'setup/loader/pom'
require 'setup/loader/rookbook'
require 'setup/loader/cmake'
require 'setup/loader/mast'
require 'setup/loader/git-version-gen'

class Setup::Source::Gem < Setup::Source::Base
   extend ::Setup::Loader
   extend ::Setup::Loader::YAML
   extend ::Setup::Loader::Pom
   extend ::Setup::Loader::Mast
   extend ::Setup::Loader::Rookbook
   extend ::Setup::Loader::Cmake
   extend ::Setup::Loader::GitVersionGen
   extend ::Setup::Log

   TYPE = 'Gem::Specification'
   BIN_IGNORES = %w(test)
   OPTION_KEYS = %i(source_file source_names gemspec spec version replace_list aliases)

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

   LOADERS = {
      /\/pom.xml$/ => :pom,
      /\/(cmake|CMakeLists.txt)$/ => :cmake,
      /\/Rookbook.props$/ => :rookbook,
      /\/GIT-VERSION-GEN$/ => :git_version_gen,
      /\/MANIFEST$/ => :manifest,
      /\/(#{Rake::Application::DEFAULT_RAKEFILES.join("|")})$/i => :app_file,
      /\.gemspec$/i => [:app_file, :yaml],
   }

   attr_reader :gem_version_replace

   Gem.load_yaml

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
         specs = Dir.glob("#{dir}/**/*", File::FNM_DOTMATCH).select {|f| File.file?(f) }.map do |f|
            LOADERS.reduce(nil) { |res, (re, _method_name)| res || re =~ f && [re, f] || nil }
         end.compact.sort do |x,y|
            c = LOADERS.keys.index(x.first) <=> LOADERS.keys.index(y.first)

            c == 0 && x.last <=> y.last || c
         end.reduce({}) do |res, (re, f)|
            load_result =
               [LOADERS[re]].flatten.reduce(nil) do |res, method_name|
                  next res if res

                  result = send(method_name, f)

                  result && result.objects.any? && result
               end

            if load_result
               gemspecs = load_result.objects.reject do |s|
                  s.loaded_from && s.loaded_from !~ /#{dir}/
               end.each {|x| x.loaded_from = f }
               log(load_result.errlog)

               res.merge({ f => gemspecs })
            else
               res
            end
         end.map do |(f, gemspecs)|
            gemspecs.map do |gemspec|
               new_if_valid(gemspec, { source_file: f }.to_os.merge(options_in))
            end
         end.flatten.compact
      end

      def new_if_valid spec, options_in = {}
         # TODO move validation to space/project
         if spec && spec.version && spec.platform == 'ruby' && spec.name !~ /\u0000/
               # && !($:&spec.full_require_paths).any? && !spec.full_require_paths.all? {|p| File.directory?(p) }
            self.new(source_options(options_in.merge(spec: spec)))
         end
      end
   end

   def gemfile
      @gemfile ||= Setup::Source::Gemfile.new({
         source_file: gemfile_name && File.join(rootdir, gemfile_name) || dsl.fake_gemfile,
         gem_version_replace: gem_version_replace,
         gem_skip_list: dsl.deps.map(&:name) | [name],
         gem_append_list: [ self.dep ]}.to_os)
   end

   def gemfile_name
      source_names.find {|x| x =~ /gemfile/i }
   end

   def dep
      Bundler::Dependency.new(name, Gem::Requirement.new(["~> #{version}"]), options: { type: :runtime })
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
      version = spec&.version&.to_s || ""
      parts = version.split(".")

      (parts[0..2] + (parts[3..-1]&.map {|x| x.to_i <= 1024 && x || nil}&.compact || [])).join(".")
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

   # tree

   def datatree
      # TODO deep_merge
      @datatree ||= super { { '.' => spec.files } }
   end

   def allfiles
      @allfiles =
         spec.require_paths.map {|x| File.absolute_path?(x) && x || File.join(x, '**', '*') }.map {|x| Dir[x] }.flatten |
         spec.executables.map {|x| Dir[File.join(spec.bindir, x)] }.flatten |
         spec.files
   end

   def allfiles_for list_in
      list_in.map do |(key, list)|
         [key, list & allfiles.map {|x| /^#{key}\/(?<rest>.*)/.match(x)&.[](:rest) }.compact ]
      end.to_h
   end

   def exttree
      @exttree ||= super
   end

   def testtree
      @testtree ||= allfiles_for(super)
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
      #require 'pry';binding.ry
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

   def rake
      @rake ||= Setup::Rake.new(File.join(rootdir, Dir["{#{Rake::Application::DEFAULT_RAKEFILES.join(",")}}"].first))
   end

   # Default group
   def group
      "Development/Ruby"
   end

   def summaries
      localize(spec.summary) || aliased {|s| s.localize(s.summary) } || descriptions
   end

   def descriptions
      localize(spec.description) || aliased {|s| localize(s.description) }
   end

   def aliased &block
      aliases.reduce(nil) {|res, a| res || a != self && block[a] }
   end

   def localize text
      text && OpenStruct.new(Setup::I18n.default_locale => text)
   end

   # Default prefix "gem" for gem names
   def name_prefix
      "gem"
   end

   def uri
      spec.homepage || aliased_uri
   end

   def vcs
      spec.metadata&.[]("source_code_uri")
   end

   def dependencies type = nil
      spec.dependencies.select { |dep| !type || dep.type == type }
   end

   def provide
      spec.version && Gem::Dependency.new(spec.name, Gem::Requirement.new(["= #{spec.version}"]), :runtime)
   end

   def licenses
      spec.licenses
   end

   protected

   def detect_root
      if spec
          files = Dir['**/**/*']
          (spec.files - files).any? && super || Dir.pwd
      else
         super
      end
   end

   def extroots
      @extroots ||= extfiles.map { |extfile| File.dirname(extfile) }
   end

   def exedir
      @exedir ||= if_exist('exe')
   end

   # system
   def initialize options_in = {}
      super

      @spec = self.class.spec_for(options_in)

      gemfile
   end

   def method_missing name, *args
      if /^aliased_(?<method>.*)/ =~ name
         aliased {|a| a.send(method, *args) }
      elsif spec.respond_to?(name)
         spec.send(name, *args)
      else
         super
      end
   end
end
