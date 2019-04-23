require 'setup/source/base'

class Setup::Source::Rakefile < Setup::Source::Base
   attr_reader :root

   class << self
      def search dir, options = {}
         Dir.glob("#{dir}/**/Rakefile", File::FNM_DOTMATCH).map do |f|
            self.new(root: File.dirname(f), aliases: options[:aliases][nil])
         end
      end
   end
end
