require 'rake'

module Setup::Gemspec::Rakefile
   RE = /\/(Rakefile|rakefile)$/

   class << self
      def parse file
         stderr = $stderr
         stdout = $stdout
         $stderr = $stdout = StringIO.new

         module_name = "M" + Random.srand.to_s
         mod_code = <<-END
            module #{module_name}
               extend(Rake::DSL)
               pre = ObjectSpace.each_object(Gem::Specification).to_a

               # NOTE this forces not to share namespace but avoid exception when calling
               # main space methods, see Rakefile of racc gem
               # also named module is required instead of anonymous one to allow root level defined methods access
               load('#{file}')

               ObjectSpace.each_object(Gem::Specification).reject { |t| pre.include?(t) }.uniq { |s| s.name }
            end
         END

         specs = module_eval(mod_code)
      rescue Exception => e
         warn(e.message)
      else
         specs.first
      ensure
         # TODO puts $stderr into common error log
         $stderr = stderr
         $stdout = stdout
      end
   end
end
