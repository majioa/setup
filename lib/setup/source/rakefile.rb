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

   def dsl
      @dsl ||= Setup::DSL.new(source_file,
                              replace_list: replace_list,
                              skip_list: (options[:gem_skip_list] || []) | [self.name],
                              append_list: options[:gem_append_list])
   end

   def rake
      @rake ||= Setup::Rake.new(source_file)
   end
end
