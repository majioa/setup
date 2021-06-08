module Setup::Gemspec::Index
   RE = /\/.index$/

   PROPS = {
      name: :name,
      version: :version,
      date: :date,
      authors: :"authors.name",
      email: :"authors.email",
      summary: :summary,
      description: :description,
      homepage: :"resources.uri![type=home]",
      "metadata.homepage_uri": :"resources.uri![type=home]",
      "metadata.allowed_push_host": "https://rubygems.org",
      "metadata.source_code_uri": :"resources.uri![type=code]",
      files: ->(this) { this["manifest"].grep(/^[^#]/) },
      bindir: "bin",
      executables: ->(this) { this["manifest"].grep(/^bin\//).map {|b| b.split("/").last } },
      require_paths: ["lib"],
      extra_rdoc_files: ->(this) { this["manifest"].grep(/\.(rdoc|md|txt)$/) },
      licenses: :"copyrights.license",
      test_files: ->(this) { this["manifest"].grep(/^(test|spec|feature)\//) },
      required_ruby_version: nil,
      _add_runtime_dependency: ->(this) do
         this["requirements"].select {|req| !req["development"] }.map { |req|
            [req["name"], req["version"]&.gsub(/[^~]+~/) { |x| /(?<v>.+)~/ =~ x ; "~> #{v}" }].compact
         }
      end,
      _add_development_dependency: ->(this) do
         this["requirements"].select {|req| req["development"] }.map { |req|
            [req["name"], req["version"]&.gsub(/[^~]+~/) { |x| /(?<v>.+)~/ =~ x ; "~> #{v}" }].compact
         }
      end
   }

   class << self
      def parse file
         dir = File.dirname(file)
         manifile = Dir.foreach(dir).select {|f| f =~ /manifest/i }.first
         return nil if !manifile

         data = YAML.load(IO.read(file)).merge("manifest" => IO.read(File.join(dir, manifile)).split("\n"))

         Gem::Specification.new do |spec|
            PROPS.each do |name, value_in|
               value =
                  case value_in
                  when Symbol
                     value_in.to_s.split(".").reduce(data) do |r, n_in|
                        /^(?<n>[^\!\[]+)(?<first>\!)?\[(?<key>[^=]*)(?:=(?<value>[^\]]+))?\]$/ =~ n_in || n = n_in
                        method = first && :first || :itself

                        r.is_a?(Array) && r.select do |x|
                           !key || value ? x[key] == value : x[key]
                        end.map do |x|
                           x[n]
                        end.send(method) || r[n]
                     end
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
                        value.each do |v|
                           if value.is_a?(Array)
                              spec.send(mname, *v)
                           else
                              spec.send(mname, v)
                           end
                        end
                     else
                        spec.send(mname, value)
                     end
                  elsif subname
                     path = subname.split(".")
                     path[0..-2].reduce(spec) {|r, n| r.send(n) }.send(:[]=, path[-1], value)
                  else
                     spec.send("#{name}=", value)
                  end
               end
            end
         end
      rescue Exception => e
         $stderr.puts "WARN [#{e.class}]: #{e.message}"
      end
   end
end
