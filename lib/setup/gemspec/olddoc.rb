require 'fileutils'

module Setup::Gemspec::Olddoc
   RE = /\/GIT-VERSION-GEN$/

   class << self
      def parse git_version_gen
         setup_pre(git_version_gen)

         dir = File.dirname(git_version_gen)
         spec = nil

         FileUtils.chdir(dir) { spec = Gem::Specification.load(File.basename(gemspec_file_of(dir))) }

         spec
      end

      def gemspec_file_of dir
         Dir.glob(File.join(dir, '*.gemspec')).first
      end

      def setup_pre git_version_gen
         dir = File.dirname(git_version_gen)
         fn = File.basename(git_version_gen)
         `cd #{dir}; ./#{fn}`

         IO.readlines("#{dir}/GIT-VERSION-FILE").each do |var|
            name, value = var.gsub(/(GIT_|\s+)/, '').split(/=/)
            ENV[name] = value
         end

         # make documentaion
         if File.directory?('Documentation')
            `make -C Documentation`
         end

         generate_manifest(dir)
      end

      def generate_manifest dir
         return if File.exist?('.manifest')
         return if File.exist?('.gem-manifest')

         files = Dir.glob("#{dir}/**/*", File::FNM_DOTMATCH).reject do |f|
            /\/\.git/ =~ f || File.directory?(f)
         end.map {|x| x.gsub(/#{dir}\/?/, '')}

         File.open(File.join(dir, '.gem-manifest'), "w") { |f| f.puts files }
         FileUtils.cp(File.join(dir, '.gem-manifest'), File.join(dir, '.manifest'))
      end

      def match_in? file, text = /.*/
         IO.read(file).split("\n").grep(text).any?
      end
   end
end
