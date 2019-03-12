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
            if !FileUtils.uptodate?('Makefile', ['extconf.rb'])
              puts "[#{dir}]$ ruby extconf.rb -- --use-system-libraries --enable-debug-build"
              ruby("extconf.rb", '--', '--use-system-libraries', '--enable-debug-build')
            end
          end
        end
      end
    end

    #
    def compile
      project.sources.each do |source|
        source.extfiles.each do |extfile|
          dir = File.join(source.root, File.dirname(extfile))

          Dir.chdir(dir) do
            puts "[#{dir}]$ make #{config.makeprog}"
            make
            FileUtils.mkdir_p File.join(source.root, ".so.#{source.name}")
            make('install', DESTDIR: File.join(source.root, ".so.#{source.name}"))
            Dir.glob(File.join(source.root, ".so.#{source.name}/**/*.so")).each do |file|
              FileUtils.touch(File.join(File.dirname(file), 'gem.build_complete'))
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

