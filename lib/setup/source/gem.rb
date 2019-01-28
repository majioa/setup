require 'setup/source'

require 'tempfile'
require 'yaml'

class Setup::Source::Gem
   BIN_IGNORES = %w(test)

   attr_reader :root, :spec, :mode, :replace_list

   class << self
      def search dir, options = {}
         gemspecs = Setup::Gemspec.kinds.map { |const| Setup::Gemspec.const_get(const) }

         specs = Dir.glob("#{dir}/**/*", File::FNM_DOTMATCH).map do |f|
            gemspecs.reduce(nil) do |s, gemspec|
               s || gemspec::RE =~ f &&
                   (spec = gemspec.parse(f)) &&
                   spec.platform == 'ruby' && #(require 'pry';binding.pry; true) &&
                    self.new(root: File.dirname(f),
                    spec: spec,
                    mode: options[:mode],
                    replace_list: options[:gem_version_replace]) || nil
            end
         end.compact

         specs.map { |x| x.name }.uniq.map { |name| specs.find { |spec| spec.name == name } }
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

   def gemspec_file
      gemspec_file = Tempfile.new('gem.')
      new_spec = spec
      new_spec.dependencies.replace(deps_but(replace_list))
      gemspec_file.puts(new_spec.to_ruby)
      gemspec_file.rewind
      gemspec_file.path
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
         extfile = spec.extensions.select { |file| /extconf\.rb$/ =~ file }.first
         extfile && File.dirname(extfile) || nil)
   end

   def ridir
      @ridir ||= ".ri.#{name}"
   end

   def dldir
      extdir
   end

   def mandir
      @mandir ||= mandirs.first
   end

   def mandirs
      @mandirs ||= %w(man Documentation doc).select do |dir|
         fulldir = File.join(root, dir)

         File.directory?(fulldir) &&
         Dir.glob("#{fulldir}/**/*.{1,2,3,4,5,6,7,8}").select { |file| File.file?(file) }.any?
      end
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
      @dlfiles ||= extdir && (
         dir = File.join(root, extdir)

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
      {
         type: 'gem',
         spec: spec.to_yaml,
         root: root,
         mode: mode,
         replace_list: replace_list
      }
   end

   protected

   def deps_but replace_list
      spec.dependencies.map do |dep|
         new_req = replace_list.reduce(nil) do |s, (name, req)|
            s || name == dep.name && req
         end

         new_req && Gem::Dependency.new(dep.name, Gem::Requirement.new([new_req]), dep.type) || dep
      end
   end

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
   def initialize root: nil, spec: nil, mode: nil, replace_list: {}
      @spec = spec.is_a?(String) && YAML.load(spec) || spec
      @root = root || Dir.pwd
      @mode = mode
      @replace_list = replace_list || {}
   end
end
