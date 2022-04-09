# used in digest-crc gem as an extension compiler
#
require 'setup/loader'

class Setup::Rake
   extend ::Setup::Loader

   class InvalidRakefileError < StandardError; end

   TYPE = 'Rake::Application'

   attr_reader :app, :rakefile

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
      Rake.instance_variable_set(:@application, @app)
      @app&.invoke_task(task_name)
   rescue Exception => e
      warn "#{e.class}: #{e.message}\n\t#{e.backtrace.join("\n\t")}"
   end

   def initialize rakefile
      raise InvalidRakefileError unless File.file?(rakefile)

      @rakefile = rakefile
      @app = self.class.load(rakefile)
   end

   class << self
      def load rakefile
         Rake.instance_variable_set(:@application, nil)
         app_file(rakefile).objects.first
      end
   end
end
