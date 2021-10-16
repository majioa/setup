module Setup::Gemspec::Gem
   RE = /\.gemspec$/

   class << self
      def load_from file
         stderr = $stderr
         $stderr = StringIO.new
         spec = Gem::Specification.load(file)
         if !spec && $stderr.pos > 0
            # TODO use filetype detection
            spec_in = YAML.load(IO.read(file))
            if spec_in.is_a?(Gem::Specification)
               spec = spec_in
            end
         end

         spec
      rescue Exception
      ensure
         # TODO puts $stderr into common error log
         $stderr.rewind
         stderr.puts $stderr.readlines.join("\n")

         $stderr = stderr
      end

      def parse file
         spec = nil

         FileUtils.chdir(File.dirname(file)) do
            spec = load_from(File.basename(file))
         end

         spec
      rescue Exception => e
         $stderr.puts "WARN [#{e.class}]: #{e.message}"
      end
   end
end
