require 'setup/base'
require 'setup/rake_app'
require 'setup/log'

module Setup
   class Compiler < Base
      include Setup::Log

      ARGS = %w(--use-system-libraries --enable-system-libraries --enable-debug-build --disable-static --enable-force-compile --srcdir=.)

      class Extconf
         attr_reader :config, :original_config, :makeconfig, :original_makeconfig, :argv, :extdir, :source

         def initialize extpath, source, *args
            @extfile = extpath
            @extdir = File.dirname(extpath)
            @argv = args
            @original_config = RbConfig::CONFIG.dup
            @original_makeconfig = RbConfig::MAKEFILE_CONFIG.dup
            @source = source

            Dir.chdir(@extdir) do
               RbConfig::MAKEFILE_CONFIG["configure_args"] = args.join(" ")
               require 'mkmf'
               RbConfig::CONFIG["srcdir"] = RbConfig::MAKEFILE_CONFIG["srcdir"] = '.'

               init_mkmf(RbConfig::MAKEFILE_CONFIG, RbConfig::CONFIG)
            end
         end

         def configure
            Dir.chdir(@extdir) do
               load(File.join('.', File.basename(@extfile)))
            end

            @config = RbConfig::CONFIG.dup
            @makeconfig = RbConfig::MAKEFILE_CONFIG.dup
         rescue SystemExit
         rescue Exception => e
            $stderr.puts("[#{e.class}]> #{e.message}\t\n#{e.backtrace.join("\t\n")}")
         ensure
            RbConfig::CONFIG.replace(@original_config)
            RbConfig::MAKEFILE_CONFIG.replace(@original_makeconfig)
         end
     end

    #
    #
    def configure
      @configurations =
        project.valid_sources.map do |source|
          source.exttree.map do |dir_in, extfiles|
            extfiles.map do |extfile|
              extpath = File.join(source.root, dir_in, extfile)

              if extpath =~ /rakefile(.rb)?$/i
                 Setup::Rake.new(extpath, {source: source})
              else
                 cfg = Extconf.new(extpath, source, *ARGS)
                 cfg.configure
                 cfg
              end
            end
          end
        end.flatten
    end

    #
    def make
      chrpath_path = `which chrpath`.strip

      @configurations.each do |cfg|
        case cfg
        when Setup::Rake
          cfg.run_task('default')
          source = cfg.options[:source]

          soes = Dir.glob(File.join(source.root, "**", "*.so"))
          if soes.any?
              # NOTE gem hotwater
              dd = File.join(source.root, ".so.#{source.name}", RbConfig::CONFIG['sitearchdir'])
              FileUtils.mkdir_p(dd)

              soes.map do |x|
                FileUtils.touch(File.join(dd, 'gem.build_complete'))
                FileUtils.cp(x, dd)
                bash(chrpath_path, '-d', File.join(dd, File.basename(x))) if !chrpath_path.empty?
              end
            end
        when Extconf
          headers = Dir.glob("*/**/*.{h,hpp}")

          Dir.chdir(cfg.extdir) do
            debug "[#{cfg.extdir}]$ make #{config.makeprog}"
            make_task

            # post make
            if Dir.glob("**/*.so").any?
              FileUtils.mkdir_p(File.join(cfg.source.root, ".so.#{cfg.source.name}", RbConfig::CONFIG['sitearchdir'], target_prefix))
              make_task('install', DESTDIR: File.join(cfg.source.root, ".so.#{cfg.source.name}"))
              Dir.glob(File.join(cfg.source.root, ".so.#{cfg.source.name}/**/*.so")).each do |file|
                FileUtils.touch(File.join(File.dirname(file), 'gem.build_complete'))

                # remove RPATH if any
                bash(chrpath_path, '-d', file) if !chrpath_path.empty?
              end
            end
          end
        end
      end
    end

    #
    def clean
      project.valid_sources.each do |source|
        source.exttree.each do |dir_in, extfiles|
          extfiles.each do |extfile|
            Dir.chdir(File.join(source.root, dir_in, File.dirname(extfile))) do
              make_task('clean')
            end
          end
        end
      end
    end

    #
    def distclean
      project.valid_sources.each do |source|
        source.exttree.each do |dir_in, extfiles|
          extfiles.each do |extfile|
            Dir.chdir(File.join(source.root, dir_in, File.dirname(extfile))) do
              Dir.glob('**/gem.build_complete').each { |file| FileUtils.rm_f(file) }
              make_task('distclean')
            end

            FileUtils.rm_rf(File.join(source.root, ".so.#{source.name}"))
          end
        end
      end
    end

    protected
    #
    #
    def make_task task = nil, env = {}
       if File.exist?('Makefile')
          args = [env, config.makeprog, task].compact
          bash(*args)
       end
    end

    def target_prefix
      IO.read("Makefile").split("\n").select do |l|
        l =~ /target_prefix *=/
      end.first.split('=')[1..-1].join('=').strip
    end

  end

end

