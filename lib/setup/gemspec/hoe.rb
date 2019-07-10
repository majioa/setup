# Hoe based gemspec detection module
# Sample gems are: hoe, racc
#

module Setup::Gemspec::Hoe
   RE = /\/Rakefile$/


   class << self
      def has_hoe?
         require('hoe') && defined? Hoe
      rescue Exception
      end

      def parse rakefile
         if File.file?(rakefile) && has_hoe?
            begin
               stdout = $stdout
               $stdout = $stderr

               require 'rake'

               module_name = "M" + Random.srand.to_s
               mod_code = <<-END
                  module #{module_name}
                     extend(Rake::DSL)
                     # NOTE this forces not to share namespace but avoid exception when calling
                     # main space methods, see Rakefile of racc gem
                     load('#{rakefile}')
                  end
               END
               module_eval(mod_code)
            rescue Exception => e
               $stderr.puts "[setup.rb]{self.class} -> #{e.class}: #{e.message}"
            else
               ObjectSpace.each_object(Hoe).map { |h| h.spec }.compact.first
            ensure
               $stdout = stdout
            end
         end
      end
   end
end
