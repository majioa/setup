class Setup::Source::Rakefile < Setup::Source::Base
   class << self
      def search dir, options_in = {}
         Dir.glob("#{dir}/**/Rakefile", File::FNM_DOTMATCH).map do |f|
            self.new(source_options(options_in.merge(rootdir: File.dirname(f))))
         end
      end
   end
end
