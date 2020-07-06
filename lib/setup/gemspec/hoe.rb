require 'rake'

require 'setup/log'
# Hoe based gemspec detection module
# Sample gems are: hoe, racc
#
module Setup::Gemspec::Hoe
   RE = /\/Rakefile$/

   class << self
      include Setup::Log

      def has_hoe?
         require('hoe')

         defined? Hoe
      rescue Exception
      end

      def parse rakefile
         if File.file?(rakefile) && has_hoe?
            begin
               stdout = $stdout
               $stdout = $stderr

               mod_code = <<-END
                  extend(Rake::DSL)
                  # NOTE this forces not to share namespace but avoid exception when calling
                  # main space methods, see Rakefile of racc gem

                  Dir.chdir(File.dirname('#{rakefile}')) do
                     load(File.basename('#{rakefile}'), true)
                  end

                  ObjectSpace.each_object(Hoe).map { |h| h.spec }.compact
               END
               specs = module_eval(mod_code)
            rescue Exception => e
               warn(e.message)
            else
               specs.first
            ensure
               $stderr = $stdout
               $stdout = stdout
            end
         end
      end
   end
end
