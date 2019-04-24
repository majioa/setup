require 'setup/base'

module Setup

  #
  class Compiler < Base

    #
    #
    def configure
      project.sources.each do |source|
        source.extfiles.each do |extfile|
          dir = File.join(source.root, File.dirname(extfile))

          Dir.chdir(dir) do
            puts "[#{dir}]$ ruby extconf.rb -- --use-system-libraries --enable-debug-build"
            ruby("extconf.rb", '--', '--use-system-libraries', '--enable-debug-build')
          end
        end
      end
    end

    #
    def compile
      chrpath_path = `which chrpath`.strip

      project.sources.each do |source|
        source.extfiles.each do |extfile|
          dir = File.join(source.root, File.dirname(extfile))

          Dir.chdir(dir) do
            puts "[#{dir}]$ make #{config.makeprog}"
            make

            # post compile
            if Dir.glob("**/*.so").any?
              FileUtils.mkdir_p File.join(source.root, ".so.#{source.name}")
              make('install', DESTDIR: File.join(source.root, ".so.#{source.name}"))
              Dir.glob(File.join(source.root, ".so.#{source.name}/**/*.so")).each do |file|
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
      project.sources.each do |source|
        source.extfiles.each do |extfile|
          dir = File.join(source.root, File.dirname(extfile))

          Dir.chdir(dir) do
            make('clean')
          end
        end
      end
    end

    #
    def distclean
      project.sources.each do |source|
        source.extfiles.each do |extfile|
          dir = File.join(source.root, File.dirname(extfile))

          Dir.chdir(dir) do
            Dir.glob('**/gem.build_complete').each { |file| FileUtils.rm_f(file) }
            make('distclean')
          end

          FileUtils.rm_rf(File.join(source.root, ".so.#{source.name}"))
        end
      end
    end

    #
    #
    def make task = nil, env = {}
       if File.exist?('Makefile')
          args = [env, config.makeprog, task].compact
          bash(*args)
       end
    end

  end

end

