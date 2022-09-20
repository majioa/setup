# used in digest-crc gem as an extension compiler
#
require 'setup/loader'

class Setup::Rake
   extend ::Setup::Loader

   class InvalidRakefileError < StandardError; end

   TYPE = 'Rake::Application'
   PRELOAD_MATCHER = { /\/rakefile(.rb)?$/i => :preload }

   attr_reader :app, :rakefile, :options

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
      if @app
         Rake.instance_variable_set(:@application, @app)

         Dir.chdir(@app.original_dir) do
            @app.invoke_task(task_name)
         end
      end
   rescue Exception => e
      warn "#{e.class}: #{e.message}\n\t#{e.backtrace.join("\n\t")}"
   end

   def initialize rakefile, options = {}
      raise InvalidRakefileError unless File.file?(rakefile)

      @rakefile = rakefile
      @options = options
      @app = self.class.load(rakefile).objects.first
      @app&.load_imports
   end

   class << self
      # preload callback
      def preload
         Rake.instance_variable_set(:@application, nil)
      end

      def load rakefile
         app_file(rakefile)
      end
   end
end
