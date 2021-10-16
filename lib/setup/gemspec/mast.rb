module Setup::Gemspec::Mast
   RE = /MANIFEST/

   PROPS = {
      name: :name,
      version: :version,
      date: :date,
      authors: :authors,
      email: ->(this) do
         /(?<email>[^\s<]+@[^\s>]+)/ =~ this["contact"]
         email
      end,
      summary: :summary,
      description: :description,
      homepage: :"resources.home", #->(this) { this["resources"]["home"] }
      "metadata.homepage_uri": :"resources.code",
      "metadata.allowed_push_host": "https://rubygems.org",
      "metadata.source_code_uri": :"resources.repo",
      files: ->(this) { this["manifest"].grep(/^[^#]/) },
      bindir: "bin",
      executables: ->(this) { this["manifest"].grep(/^bin\//).map {|b| b.split("/").last } },
      require_paths: ["lib"],
      extra_rdoc_files: ->(this) { this["manifest"].grep(/\.(rdoc|md)$/) },
      licenses: ->(this) do
         if license = this["manifest"].grep(/LICENSE/).first
            lic = IO.read(license).split("\n")
            if type = lic.reduce(nil) { |r, l| r || /(?<type>Apache|MIT)/ =~ l && type }
               version = lic.reduce(nil) { |r, l| r || /Version (?<version>[\d\.]+)/ =~ l && version }
               [[ type, version ].compact.join("-") ]
            end
         end
      end,
      test_files: ->(this) { this["manifest"].grep(/^(test|spec|feature)\//) },
      required_ruby_version: nil,
      _add_development_dependency: ->(this) do
         this["requires"].map { |line| /^(?<req>[^\s(]+)/.match(line)["req"] }
      end
   }

   class << self
      def parse file
         spec = nil
         dir = File.dirname(file)
         file1 = File.join(dir, "meta", "package")
         file2 = File.join(dir, "meta", "profile")

         if File.file?(file1) && File.file?(file2)
            Gem::Specification.new do |s|
               data = YAML.load(IO.read(file1)).merge(YAML.load(IO.read(file2))).merge("manifest" => IO.read("MANIFEST").split("\n"))
               PROPS.each do |name, value_in|
                  value =
                     case value_in
                     when Symbol
                        value_in.to_s.split(".").reduce(data) {|r, n| r[n] }
                     when Proc
                        value_in[data]
                     when NilClass
                     else
                        value_in
                     end

                  if value
                     method_name = /^(?:_(?<mname>[^\.]+)|(?<subname>[^\.]+\..+)|.*)/ =~ name.to_s
                     if mname
                        if value.is_a?(Array)
                           value.each { |v| s.send(mname, v) }
                        else
                           s.send(mname, value)
                        end
                     elsif subname
                        path = subname.split(".")
                        path[0..-2].reduce(s) {|r, n| r.send(n) }.send(:[]=, path[-1], value)
                     else
                        s.send("#{name}=", value)
                     end
                  end
               end
            end
         end
      rescue Exception => e
         $stderr.puts "WARN [#{e.class}]: #{e.message}"
      end
   end
end
