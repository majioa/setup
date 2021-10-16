require 'setup/source/base'
require 'setup/rake_app'

class Setup::Source::Rakefile < Setup::Source::Base
   class << self
      def search dir, options_in = {}
         Dir.glob("#{dir}/**/Rakefile", File::FNM_DOTMATCH).map do |f|
            self.new(source_options({ root: File.dirname(f) }.merge(options_in)))
         end
      end
   end

   def rake
      @rake ||= Setup::Rake.new(File.join(options[:root]))
   end
end
