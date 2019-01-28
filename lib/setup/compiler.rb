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
            if Dir.glob('**/*.so').any?
              FileUtils.touch('gem.build_complete')
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
            make('distclean')
          end
        end
      end
    end

    #
    #
    def make task = nil
       if File.exist?('Makefile')
          bash(*[config.makeprog, task].compact)
       end
    end

  end

end

