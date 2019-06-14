require 'setup/source/base'

require 'tempfile'
require 'yaml'

class Setup::Source::Gem < Setup::Source::Base
   BIN_IGNORES = %w(test)
   OPTION_KEYS = %i(root spec mode version replace_list aliases)

   attr_reader :root, :spec, :mode

   class << self
      def search dir, options = {}
         gemspecs = Setup::Gemspec.kinds.map { |const| Setup::Gemspec.const_get(const) }

         gemspec_files = Dir.glob("#{dir}/**/*", File::FNM_DOTMATCH).map do |f|
            gemspecs.map do |gemspec|
               gemspec::RE =~ f && [ gemspec, f ] || nil
            end
         end.flatten(1).compact.sort_by do |(gemspec, _)|
            gemspecs.index(gemspec)
         end

         specs = gemspec_files.map do |gemspec, f|
            #require 'pry';binding.pry
            new_if_valid(gemspec.parse(f), File.dirname(f), options)
         end.flatten(1).compact

         specs.map { |x| x.name }.uniq.map { |name| specs.find { |spec| spec.name == name } }
      end

      def new_if_valid spec, dir, options = {}
         if spec && spec.platform == 'ruby'
            self.new(root: dir,
                     spec: spec,
                     mode: options[:mode],
                     version: options[:version_replaces][spec.name] || options[:version_replaces][nil],
                     aliases: (options[:aliases][nil] || []) | (options[:aliases][spec.name] || []),
                     replace_list: options[:gem_version_replace])
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

   # many dirs

   def require_pure_paths
      @require_pure_paths ||= (
         paths = spec.require_paths.select { |path| path !~ /\// }
         paths.any? && paths || ['lib'])
   end

   def doc_sourcedirs
      require_pure_paths
   end

   # single dir

   def require_dir
      require_pure_paths.first
   end

   def libdir
      @libdir ||= mode == :lust && 'lib' || require_dir
   end

   def datadir
      '.'
   end

   def bindir
      @bindir ||= spec.bindir || exedir || 'bin'
   end

   def extdir
      @extdir ||= (
         spec.extensions.select { |file| /extconf\.rb$/ =~ file }.map { |file| File.dirname(file) }.uniq.first)
   end

   def ridir
      @ridir ||= ".ri.#{name}"
   end

   def dldir
      @dldir ||= (
         dir = ".so.#{name}#{RbConfig::CONFIG['sitearchdir']}"

         File.directory?(File.join(root, dir)) && dir || nil)
   end

   def mandir
      @mandir ||= mandirs.first
   end

   def includedir
      extdir
   end

   # files

   def libfiles
      @libfiles ||= (
         dir = File.join(root, libdir)

         if File.exist?(dir)
           Dir.chdir(dir) do
             files_in = Dir.glob("**/*").select { |file| File.file?(file) }
             if mode == :strict
                files_declared = spec.files.select {|file| file =~ /^#{libdir}\// }.map { |file| /^#{libdir}\/(?<rest>.*)/ =~ file ; rest }
                (files_declared & files_in)
             else files_in
             end
           end
         end || [])
   end

   def datafiles
      @datafiles ||= (
         Dir.chdir(File.join(root, datadir)) do
         f =
         if mode == :strict
           files_in = Dir.glob("**/*").select { |file| File.file?(file) }
           spec.files.reject {|file| file =~ /^#{libdir}\// }
           # strict list based on files
           #files_in = spec.files.any? && spec.files.select { |file| /\.rb$/ !~ file && /^(#{non_data_pure_paths.join('|')})\// !~ file }
           # (files_in ||
           # (Dir.glob("**/*").select { |file| !/^#{datadir}\/?(#{non_data_pure_paths.join('|')})\/.*/.match(file) } +
           #  Dir.glob("#{root}/{#{require_pure_paths.join(',')}}/**/*").select { |file| /\.rb$/ !~ file }))
         else
           # method based on files including "require_pure_paths"
           files_in = spec.files.select { |file| /\.rb$/ !~ file && /^(#{non_data_pure_paths.join('|')})\// !~ file }

           (files_in.any? && files_in ||
            (Dir.glob("**/*").select { |file| !/^#{datadir}\/?(#{non_data_pure_paths.join('|')})\/.*/.match(file) }))
          end.select { |file| File.file?(file) }
          f
         end)
   end

   def rifiles
      @rifiles ||= (
         dir = File.join(root, ridir)

         if File.exist?(dir)
           Dir.chdir(dir) do
             Dir.glob("**/*.ri").select { |file| File.file?(file) }
           end
         end || [])
   end

   def extfiles
      @extfiles ||= extdir && (
         dir = File.join(root, extdir)

         if File.exist?(dir)
            Dir.chdir(dir) do
               spec.extensions.select { |file| /extconf\.rb$/ =~ file }
            end
         end || []) || []
   end

   def dlfiles
      @dlfiles ||= dldir && (
         dir = File.join(root, dldir)

         if File.exist?(dir)
            Dir.chdir(dir) do
              Dir.glob("**/*.{#{dlext},build_complete}").select { |file| File.file?(file) }
            end
         end || []) || []
   end

   def binfiles
      @binfiles ||= spec.executables.map { |x| x.split('/').last }
   end

   def manfiles
      @manfiles ||= mandir && (
         dir = File.join(root, mandir)

         if File.exist?(dir)
            Dir.chdir(dir) do
               Dir.glob("**/*.{1,2,3,4,5,6,7,8}").select { |file| File.file?(file) }
            end
         end || []) || []
   end

   def includefiles
      @includefiles ||= includedir && (
         dir = File.join(root, includedir)
         if File.exist?(dir)
            Dir.chdir(dir) do
               Dir.glob("**/*.h{,pp}").select { |file| File.file?(file) }
            end
         end || []) || []
   end

   def doc_sourcefiles
      doc_sourcedirs + spec.extra_rdoc_files
   end

   # custom

   def extroot_for file
      extroots.find { |extroot| extroot == file[0...extroot.size] }
   end

   def non_data_pure_paths
      %w(spec test bin exe feature acceptance docs man Documentation benchmarks ri examples yardoc ext autotest .git tmp vendor sample) + require_pure_paths
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
      super.merge(
         spec: spec.to_yaml,
         mode: mode)
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

   protected

   def extroots
      @extroots ||= extfiles.map { |extfile| File.dirname(extfile) }
   end

   def dlext
      RbConfig::CONFIG['DLEXT']
   end

   def exedir
      @exedir ||= File.exist?(File.join(root, 'exe')) && 'exe' || nil
   end

   #
   def initialize root: nil, spec: nil, mode: nil, replace_list: {}, version: nil, aliases: nil
      super(root: root, replace_list: replace_list, aliases: aliases)

      @spec = spec.is_a?(String) && YAML.load(spec) || spec
      @mode = mode
      @spec.version = Gem::Version.new(version) if version
   end
end
