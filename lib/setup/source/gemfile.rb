require 'setup/dsl'
require 'setup/source/base'

class Setup::Source::Gemfile < Setup::Source::Base
   class << self
      def search dir, options_in = {}
         Dir.glob("#{dir}/**/Gemfile", File::FNM_DOTMATCH).map do |f|
            self.new(source_options({ root: File.dirname(f) }.merge(options_in)))
         end
      end
   end

   def gemfile_path
      gemspec_file = Tempfile.new('Gemfile.')
      gemspec_file.puts(dsl.to_gemfile)
      gemspec_file.rewind
      gemspec_file.path
   end

   def dsl
      @dsl ||= Setup::DSL.new(source: self, replace_list: replace_list)
   end

   def valid?
      dsl.valid?
   end
end
