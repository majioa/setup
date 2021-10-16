class Setup::Rake
   attr_reader :app, :rakefile

   def load
      stdout = $stdout
      $stdout = $stderr

      pre = ObjectSpace.each_object(Gem::Specification).to_a.map(&:__id__)
      self.class.load(rakefile)
   rescue Exception => e
      warn(e.message)
   ensure
      @@specs = ObjectSpace.each_object(Gem::Specification).reject { |t| pre.include?(t.__id__) }.uniq { |s| s.name }
      $stderr = $stdout
      $stdout = stdout
   end

   def blank?
      !@app
   end

   def present?
      !!@app
   end

   def tasks
      @tasks ||= @app&.tasks || []
   end

   def run_task task_name
      @app&.invoke_task(task_name)
   rescue Exception => e
      warn "#{e.class}: #{e.message}\n\t#{e.backtrace.join("\n\t")}"
      #require 'pry';binding.pry
   end

   def initialize rakedir
      @rakefile =
         ::Rake::Application::DEFAULT_RAKEFILES.map do |f|
            File.join(rakedir, f)
         end.find do |f|
            File.file?(f)
         end

      if rakefile
         @app = load
      end
   end

   class << self
      def load rakefile
         module_name = "M" + Random.srand.to_s
         mod_code = <<-END
            module #{module_name}
               extend(Rake::DSL)
               # NOTE this forces not to share namespace but avoid exception when calling
               # main space methods, see Rakefile of racc gem
               Dir.chdir(File.dirname('#{rakefile}')) do
                  load(File.basename('#{rakefile}'), true)
               end

               app = Rake.instance_variable_get(:@application)
               Rake.instance_variable_set(:@application, nil)
               app
            end
         END
         module_eval(mod_code)
      end
   end
end
