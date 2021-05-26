class Setup::Source::Gemfile < Setup::Source::Base
   class << self
      def search dir, options_in = {}
         Dir.glob("#{dir}/**/Gemfile", File::FNM_DOTMATCH).map do |f|
            self.new(source_options(options_in.merge(rootdir: File.dirname(f))))
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
      @dsl ||= Setup::DSL.new(source: self,
                              replace_list: replace_list,
                              skip_list: options[:gem_skip_list],
                              append_list: options[:gem_append_list])
   end

   def valid?
      dsl.valid?
   end
end
