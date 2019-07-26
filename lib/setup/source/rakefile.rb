require 'setup/source/base'

class Setup::Source::Rakefile < Setup::Source::Base
   class << self
      def search dir, options_in = {}
         Dir.glob("#{dir}/**/Rakefile", File::FNM_DOTMATCH).map do |f|
            self.new(source_options({ root: File.dirname(f) }.merge(options_in)))
         end
      end
   end
end
