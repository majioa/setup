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
         $stderr = stderr
      end

      def parse file
         spec = nil

         dir = File.dirname(file)
         $:.unshift(File.join(dir, "lib"))
         $:.unshift(dir)
         FileUtils.chdir(dir) { spec = load_from(File.basename(file)) }
         if !spec
            module_name = "M" + Random.srand.to_s
            propfile = File.basename(file)
            mod_code = <<-END
               module #{module_name}
                  extend(Rake::DSL)
                  # NOTE this forces not to share namespace but avoid exception when calling
                  # main space methods, see Rakefile of racc gem
                  # also named module is required instead of anonymous one to allow root level defined methods access
                  load('#{propfile}')
               end
            END
            spec_ids = ObjectSpace.each_object(Gem::Specification).to_a.map {|s|s.__id__}
            FileUtils.chdir(dir) { module_eval(mod_code) }
            spec = ObjectSpace.each_object(Gem::Specification).to_a.select {|s| !spec_ids.include?(s.__id__) }.first
         end

         spec
      rescue Exception => e
         $stderr.puts "WARN [#{e.class}]: #{e.message}"
      ensure
         $:.shift
         $:.shift
      end
   end
end
