require 'setup/source/base'

class Setup::Source::Gemfile < Setup::Source::Base
   attr_reader :root

   class << self
      def search dir, _ = {}
         Dir.glob("#{dir}/**/Gemfile", File::FNM_DOTMATCH).map do |f|
            self.new(root: File.dirname(f))
         end
      end
   end
end
