require 'rake'

require 'setup/log'
# PackageTask based gemspec detection module
# Sample is: ruby-gnome2
#
module Setup::Gemspec::PackageTask
   RE = /\/Rakefile$/

   class << self
      include Setup::Log

      def parse rakefile
         if rakefile && File.file?(rakefile)
            begin
               stdout = $stdout
               stderr = $stderr
               $stdout = $stderr = Tempfile.new('package-task')

               require 'rake'
               require 'rubygems/package_task'

               mod_code = <<-END
                  extend(Rake::DSL)

                  pre = ObjectSpace.each_object(Gem::PackageTask).to_a

                  dir = File.dirname('#{rakefile}')
                  Dir.chdir(dir) do
                     load('#{rakefile}', true)
                     # in some cases __dir__ is nil inside the Rakefile, but should not
                     #__dir__ ||= dir
                     #eval(IO.read('#{rakefile}'))
                  end

                  ObjectSpace.each_object(Gem::PackageTask).reject { |t| pre.include?(t) }.map { |h| h.gem_spec }.uniq { |s| s.name }
               END
               specs = module_eval(mod_code)
            rescue Exception => e
               warn(e.message)
            else
               specs.first
            ensure
               $stdout.unlink
               $stderr = stderr
               $stdout = stdout
            end
         end
      end
   end
end
