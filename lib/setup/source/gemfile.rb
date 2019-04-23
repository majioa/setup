require 'setup/dsl'
require 'setup/source/base'

class Setup::Source::Gemfile < Setup::Source::Base
   class << self
      def search dir, options = {}
         Dir.glob("#{dir}/**/Gemfile", File::FNM_DOTMATCH).map do |f|
            self.new(root: File.dirname(f), aliases: options[:aliases][nil])
         end
      end
   end

   def dsl
      @dsl ||= Setup::DSL.new(source: self, replace_list: replace_list)
   end

   def valid?
      dsl.valid?
   end
end
