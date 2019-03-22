require 'setup/dsl'
require 'setup/source/base'

class Setup::Source::Gemfile < Setup::Source::Base
   class << self
      def search dir, _ = {}
         Dir.glob("#{dir}/**/Gemfile", File::FNM_DOTMATCH).map do |f|
            self.new(root: File.dirname(f))
         end
      end
   end

   def dsl
      @dsl ||= Setup::DSL.new(source: self)
   end

   def valid?
      dsl.valid?
   end
end
