require 'setup/loader'

class Setup::Rake
   extend ::Setup::Loader

   TYPE = 'Jeweler::Tasks'

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
         mm = app_file(rakefile) do |_|
            app = Rake.instance_variable_get(:@application)
            Rake.instance_variable_set(:@application, nil)
            app
         end

         mm.objects.first
      end
   end
end
