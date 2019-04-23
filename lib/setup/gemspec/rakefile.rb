module Setup::Gemspec::Rakefile
   RE = /\/Rakefile$/

   class << self
      def parse rakefile
         if File.file?(rakefile)
            begin
               stdout = $stdout
               $stdout = $stderr

               require 'rake'

               module_name = "M" + Random.srand.to_s
               mod_code = <<-END
                  module #{module_name}
                     extend(Rake::DSL)
                     class_eval(IO.read('#{rakefile}'))
                  end
               END
               module_eval(mod_code)
            rescue Exception => e
               $stderr.puts "[setup.rb] -> #{e.class}: #{e.message}"
            else
               space = const_get(module_name)
               space.constants.map {|x| space.const_get(x) }.find { |x| x.is_a?(Gem::Specification) }
            ensure
               $stdout = stdout
            end
         end
      end
   end
end
