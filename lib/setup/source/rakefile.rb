require 'setup/source/base'
require 'setup/rake_app'

class Setup::Source::Rakefile < Setup::Source::Base
   class << self
      def search dir, options_in = {}
         Dir.glob("#{dir}/**/Rakefile", File::FNM_DOTMATCH).select {|f| File.file?(f) }.map do |f|
            self.new(source_options({ source_file: f }.merge(options_in)))
         end
      end
   end

   def rake
      @rake ||= Setup::Rake.new(source_file)
   end
end
