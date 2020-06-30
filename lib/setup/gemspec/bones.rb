# Hoe based gemspec detection module
# Sample gems are: bones, loquacious, little-plugger
#
require 'rake'

module Setup::Gemspec::Bones
   RE = /\/Rakefile$/

   class << self
      def parse rakefile
         if File.file?(rakefile)
            begin
               stdout = $stdout
               $stdout = $stderr

               module_name = "M" + Random.srand.to_s
               mod_code = <<-END
                  module #{module_name}
                     extend(Rake::DSL)
                     # NOTE this forces not to share namespace but avoid exception when calling
                     # main space methods, see Rakefile of racc gem
                     load('#{rakefile}')
                     if defined? ::Bones
                        ::Bones.config.gem._spec.version && ::Bones.config.gem._spec
                     end
                  end
               END
               module_eval(mod_code)
            rescue Exception => e
               $stderr.puts "[setup.rb]{self.class} -> #{e.class}: #{e.message}"
            ensure
               $stdout = stdout
            end
         end
      end
   end
end
