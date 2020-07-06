require 'rake'

require 'setup/log'

# Echoe based gemspec detection module
# Sample gems are: echoe
#
module Setup::Gemspec::Echoe
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

                  # NOTE after the block is finished all the local vars are disappeared, so
                  # do processing spec here
                  if defined? ::Echoe
                     ObjectSpace.each_object(::Echoe).map { |h| h.spec }.uniq { |x| x.name }
                  end
               END
               specs = module_eval(mod_code) || []
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
