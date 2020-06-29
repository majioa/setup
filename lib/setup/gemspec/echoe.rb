# Echoe based gemspec detection module
# Sample gems are: echoe
#
module Setup::Gemspec::Echoe
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
                     # NOTE after the block is finished all the local vars are disappeared, so
                     # do processing spec here
                     if defined? ::Echoe
                        ObjectSpace.each_object(::Echoe).map { |h| h.spec }.uniq { |x| x.name }
                     end
                  end
               END
               specs = module_eval(mod_code) || []
            rescue Exception => e
               $stderr.puts "[setup.rb]{self.class} -> #{e.class}: #{e.message}"
            else
               specs.first
            ensure
               $stdout = stdout
            end
         end
      end
   end
end
