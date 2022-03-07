# default gem specification based gemspec detection module
# example: "polyglot" gem
#
require 'setup/loader'

module Setup::Gemspec::Gem
   extend ::Setup::Loader

   RE = /\.gemspec$/i
   TYPE = 'Gem::Specification'

   class << self
      def load_from file
         stderr = $stderr
         $stderr = StringIO.new
         spec = Gem::Specification.load(file)
         if !spec && $stderr.pos > 0
            # TODO use filetype detection
            spec_in = YAML.load(IO.read(file))
            if spec_in.is_a?(Gem::Specification)
               spec = spec_in
            end
         end

         spec
      rescue Exception
      ensure
         # TODO puts $stderr into common error log
         $stderr = stderr
      end

      def parse file
         dir = File.dirname(file)
         $:.unshift(File.join(dir, "lib"))
         $:.unshift(dir)
         spec = FileUtils.chdir(dir) { load_from(File.basename(file)) }

         spec || app_file(file).objects.first
      ensure
         $:.shift
         $:.shift
      end
   end
end
