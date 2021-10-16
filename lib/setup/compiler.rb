require 'setup/base'

module Setup

  #
   class Compiler < Base
      class Extconf
         attr_reader :config, :original_config, :makeconfig, :original_makeconfig, :argv

         def initialize extfile, *args
            @extfile = extfile
            @argv = args
            @original_config = RbConfig::CONFIG.dup
            @original_makeconfig = RbConfig::MAKEFILE_CONFIG.dup
            #@oargv = ARGV.dup
            RbConfig::MAKEFILE_CONFIG["configure_args"] = args.join(" ")
            require 'mkmf'
            RbConfig::CONFIG["srcdir"] = RbConfig::MAKEFILE_CONFIG["srcdir"] = '.'

            init_mkmf(RbConfig::MAKEFILE_CONFIG, RbConfig::CONFIG)
            # $0.replace(File.join(File.dirname(extfile), "fake"))
         end

         def configure
            #ARGV.replace(@argv)
            #binding.pry
            load(File.basename(@extfile))

            # module_eval("load('#{File.basename(extfile)}')")
            @config = RbConfig::CONFIG.dup
            @makeconfig = RbConfig::MAKEFILE_CONFIG.dup
         rescue SystemExit
         rescue Exception => e
            $stderr.puts("[#{e.class}]> #{e.message}\t\n#{e.backtrace.join("\t\n")}")
         ensure
            # $0.replace(cmd)
            #ARGV.replace(@oargv)
            RbConfig::CONFIG.replace(@original_config)
            RbConfig::MAKEFILE_CONFIG.replace(@original_makeconfig)
         end
     end

    #
    #
    def configure
      @configurations =
        project.sources.map do |source|
          source.exttree.map do |dir_in, extfiles|
            extfiles.map do |extfile|
              Dir.chdir(File.join(source.root, dir_in, File.dirname(extfile))) do
                 # binding.pry
                 Extconf.new(extfile, '--use-system-libraries', '--enable-debug-build', '--disable-static', '--srcdir=.').configure
              end
            end
          end
        end.flatten
    end

    #
    def make
      chrpath_path = `which chrpath`.strip

      project.sources.each do |source|
        source.exttree.each do |dir_in, extfiles|
          extfiles.each do |extfile|
            dir = File.join(source.root, dir_in, File.dirname(extfile))
            headers = Dir.glob("*/**/*.{h,hpp}")

            Dir.chdir(dir) do
              puts "[#{dir}]$ make #{config.makeprog}"
              make_task

              # post make
              if Dir.glob("**/*.so").any?
                FileUtils.mkdir_p File.join(source.root, ".so.#{source.name}", RbConfig::CONFIG['sitearchdir'], target_prefix)
                make_task('install', DESTDIR: File.join(source.root, ".so.#{source.name}"))
                Dir.glob(File.join(source.root, ".so.#{source.name}/**/*.so")).each do |file|
                  FileUtils.touch(File.join(File.dirname(file), 'gem.build_complete'))

                  # remove RPATH if any
                  bash(chrpath_path, '-d', file) if !chrpath_path.empty?
                end
              end

              #cleanup

            end
          end
        end
      end
    end

    #
    def clean
      project.sources.each do |source|
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
      project.sources.each do |source|
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

