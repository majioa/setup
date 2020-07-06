require 'rake'

require 'setup/log'

# Hoe based gemspec detection module
# Sample gems are: bones, loquacious, little-plugger
#
module Setup::Gemspec::Bones
   RE = /\/Rakefile$/

   class << self
      include Setup::Log

      def parse rakefile
         if File.file?(rakefile)
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

                  if defined? ::Bones
                     ::Bones.config.gem._spec.version && ::Bones.config.gem._spec
                  end
               END
               module_eval(mod_code)
            rescue Exception => e
               warn(e.message)
            ensure
               $stderr = $stdout
               $stdout = stdout
            end
         end
      end
   end
end
