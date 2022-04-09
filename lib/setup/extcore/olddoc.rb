module Olddoc
   module Gemspec
      def readme_metadata
         @metadata ||=
            (/= (?<name>\w+)\!?\s*-\s*(?<desc>.*)\n/ =~ File.readlines(readme_path)[0]
            [ name, desc, "#{name} - #{desc}" ])
      end

      def readme_description
         @description ||= File.read(readme_path).split(/\n\n/)[1]
      end

      def readme_path
         Dir["README*"].first
      end

      def extra_rdoc_files manifest
         @extra_rdoc_files ||= 
            manifest & File.readlines('.document').map(&:strip)
      end

      def rdoc_options
         ""
      end
   end

   class << self
      def config file = nil
         if !file
            file = Dir["{.olddoc,.wrongdoc}.yml"].first
         end

         @config ||= YAML.load(IO.read(file))
      end

#      def setup_pre git_version_gen
#         IO.readlines("GIT-VERSION-FILE").each do |var|
#            name, value = var.gsub(/(GIT_|\s+)/, '').split(/=/)
#            ENV[name] = value
#         end

      # make documentaion
      if File.directory?('Documentation')
         `make -C Documentation`
      end

      if !File.exist?('.manifest') || !File.exist?('.gem-manifest')

         files = Dir.glob("**/*", File::FNM_DOTMATCH).reject do |f|
            /\/\.git/ =~ f || File.directory?(f)
         end

         File.open(File.join('.gem-manifest'), "w") { |f| f.puts files }
         FileUtils.cp('.gem-manifest', '.manifest')
      end
   end
end

Wrongdoc = Olddoc
