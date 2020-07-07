require 'rake'

require 'setup/log'
# Hoe based gemspec detection module
# Sample gems are: hoe, racc, nokogiri
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
               stderr = $stderr
               $stdout = $stderr = Tempfile.new('package-task')

               module_name = "M" + Random.srand.to_s
               mod_code = <<-END
                  module #{module_name}
                     extend(Rake::DSL)
                     # NOTE this forces not to share namespace but avoid exception when calling
                     # main space methods, see Rakefile of racc gem
                     # also named module is required instead of anonymous one to allow root level defined methods access
                     load('#{rakefile}')
                  end

                  ObjectSpace.each_object(Hoe).map { |h| h.spec }.compact
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
