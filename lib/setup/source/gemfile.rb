require 'setup/dsl'
require 'setup/source/base'

class Setup::Source::Gemfile < Setup::Source::Base
   def gemfile_path
      gemspec_file = Tempfile.create('Gemfile.')
      gemspec_file.puts(dsl.to_gemfile)
      gemspec_file.rewind
      gemspec_file.path
   end

   def dsl
      @dsl ||= Setup::DSL.new(source: self,
                              replace_list: replace_list,
                              skip_list: options[:gem_skip_list],
                              append_list: options[:gem_append_list])
   end

   def valid?
      dsl.valid?
   end

   def rake
      @rake ||= Setup::Rake.new(File.join(options[:root]))
   end

   class << self
      def search dir, options_in = {}
         Dir.glob("#{dir}/**/Gemfile", File::FNM_DOTMATCH).map do |f|
            self.new(source_options({ root: File.dirname(f) }.merge(options_in)))
         end
      end
   end
end
