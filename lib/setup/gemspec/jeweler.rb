# POM xml based gemspec detection module
# example: "polyglot" gem
#
module Setup::Gemspec::Jeweler
   RE = /\/Rakefile$/

   class << self
      def parse propfile
         begin
            stdout = $stdout
            stderr = $stderr
            $stdout = $stderr = Tempfile.new('package-task')

            module_name = "M" + Random.srand.to_s
            mod_code = <<-END
               module #{module_name}
                  def self.specs
                     @objects
                  end

                  extend(Rake::DSL)
                  # NOTE this forces not to share namespace but avoid exception when calling
                  # main space methods, see Rakefile of racc gem
                  # also named module is required instead of anonymous one to allow root level defined methods access
                  load('#{propfile}')

                  @objects = ObjectSpace.each_object(Jeweler::Tasks).map { |h| h.spec }.compact
               end

               #{module_name}
            END
            specs = module_eval(mod_code).specs
         rescue Exception => e
            warn(e.message)
         else
            specs.first
         ensure
            $stderr = stderr
            $stdout = stdout
         end
      end
   end
end
