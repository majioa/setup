module Setup::Gemspec::Rakefile
   RE = /\/Rakefile$/

   MATCHERS = {
      proc { defined? Hoe } => proc { ObjectSpace.each_object(Hoe).map { |h| h.spec }.compact.first },
      proc { true } => proc { |space| space.constants.map {|x| space.const_get(x) }.find { |x| x.is_a?(Gem::Specification) } }
   }

   class << self
      def parse rakefile
         if rakefile && File.file?(rakefile)
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
               MATCHERS.reduce(nil) do |spec, (query, speccer)|
                  spec || query[] && speccer[const_get(module_name)] || nil
               end
            ensure
               $stdout = stdout
            end
         end
      end
   end
end
