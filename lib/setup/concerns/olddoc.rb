require 'setup/concerns'

module Setup::Concerns::Olddoc
   def readme_metadata
      @metadata ||=
         (/= (?<name>\w+)\!?\s*-\s*(?<desc>.*)\n/ =~ File.readlines(readme_path)[0]
         [ name, desc, "#{name} - #{desc}" ])
   end

   def readme_description
      @description ||= File.read(readme_path).split(/\n\n/)[1]
   end

   def readme_path
      'README'
   end

   def extra_rdoc_files manifest
      @extra_rdoc_files ||= 
         manifest & File.readlines('.document').map(&:strip)
   end

   def rdoc_options
      ""
   end

   module ClassMethods
      def config
        @config ||= YAML.load(IO.read(configname))
      end
   end
end
