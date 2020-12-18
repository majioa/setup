require 'setup/base'

module Setup

  #
  class Compiler < Base

    #
    #
    def configure
      project.sources.each do |source|
        source.exttree.each do |dir_in, extfiles|
          extfiles.each do |extfile|
            Dir.chdir(File.join(source.root, dir_in, File.dirname(extfile))) do
              ruby("extconf.rb", '--', '--use-system-libraries', '--enable-debug-build')
            end
          end
        end
      end
    end

    #
    def make
      chrpath_path = `which chrpath`.strip

      project.sources.each do |source|
        source.exttree.each do |dir_in, extfiles|
          extfiles.each do |extfile|
            dir = File.join(source.root, dir_in, File.dirname(extfile))

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

