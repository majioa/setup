module Setup::Gemspec::Hoe
   RE = /\/Rakefile$/

   class << self
      def parse rakefile
         if rakefile && File.file?(rakefile) && defined? Hoe
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
               $stderr.puts "[setup.rb] -> #{e.class}: #{e.message}"
            else
               ObjectSpace.each_object(Hoe).map { |h| h.spec }.compact.first
            ensure
               $stdout = stdout
            end
         end
      end
   end
end
