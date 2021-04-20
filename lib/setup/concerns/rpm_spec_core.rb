require "json"

module Setup::RpmSpecCore
   URL_MATCHER = {
      /(?<proto>https?:\/\/)?(?<user>[^\.]+).github.io\/(?<page>[^\/]+)/ => ->(m) do
         "https://github.com/#{m["user"]}/#{m["page"]}.git"
      end,
      /(?<proto>https?:\/\/)?github.com\/(?<user>[^\/]+)\/(?<page>[^\/]+)/ => ->(m) do
         "https://github.com/#{m["user"]}/#{m["page"]}.git"
      end
   }

   def of_space name
      space.respond_to?(name) && space.send(name) || nil
   end

   def of_source name
      source.send(name) || nil
   rescue NameError
      nil
   end

   def of_state name
      state.has_key?(name.to_s) && state[name.to_s] || nil
   end

   def of_options name
      options[name]
   end

   def of_default name
      default = self.class::STATE[name][:default]

        #    binding.pry if name == :summaries
      default.is_a?(Proc) && default[self] || default
   end

   def [] name
      instance_variable_get(:"@#{name}")
   end

   def []= name, value
      instance_variable_set(:"@#{name}", value)
   end

   def read_attribute name, seq = nil
      aa = (seq || self.class::STATE[name][:seq]).reduce(nil) do |value_in, func|
       #binding.pry if name == :summaries
         if func[0] == "_"
            send(func, value_in)
         else
            value_in || send(func, name)
         end
      end
      # binding.pry if name == :summaries
      aa
   end

   def options
      @options ||= {}
   end

   def state
      @state ||= {}
   end

#   def context
#      #require 'pry';binding.pry
#      @context ||= self["context"] ||
#         self.respond_to?(:spec) && self.spec.context ||
#         OpenStruct.new
#   end
#
   def summary
      summaries[""]
   end

   # +executable_name+ returns a name of the executable package, based on
   # the all the sources executables.
   #
   # spec.executable_name # => foo
   #
   def executable_name
      # TODO make smart selection of executable name
      @executable_name =
         if executables.size > 1
            max = executables.max { |x| x.size }.size
            exec_map = executables.map {|exec| (exec + " " * (max - exec.size)).unpack("U*") }
            filter = [45, 46, 95]

            exec_map.transpose.reverse.reduce([]) do |r, chars|
               if (chars | filter).size == chars.size || ([ chars.first ] | chars).size == 1
                  r.concat([ chars.first ])
               else
                  []
               end
            end.reverse.pack("U*")
         else
            executables.first&.gsub(/[_\.]/, '-') || ""
         end
   end

   def prefix
      name.default_prefix
   end

   protected

   def _name value_in
      return value_in if value_in.is_a?(Setup::Spec::Rpm::Name)

      name = is_exec? && executable_name.size >= 3 && executable_name || value_in

      Setup::Spec::Rpm::Name.parse(name, kind: kind, prefix: options[:name_prefix])
   end

   def _devel _in = nil
      dependencies | devel_sources
   end

   def _devel_sources _in = nil
      files.grep(/.*\.h/)
   end

   def _docs _in = nil
      of_source(:docs) || of_default(:docs)
   end

   def _summaries value_in
      source_name = source&.name

      Setup::I18n.defaulted_locales.map do |locale_in|
         locale = locale_in.blank? && Setup::I18n.default_locale || locale_in
         summary = value_in[locale] || value_in[locale_in]

         [ locale_in, t(:"spec.rpm.#{self.kind}.summary", locale: locale, binding: binding) ]
      end.reject { |_, d| d.blank? }.to_os
   end

   def _devel_requires value_in
      value_in ||= source.dependencies

      value_in.reduce([]) do |deps, dep|
         deph = Setup::Deps.to_rpm(dep.requirement)
         deps | deph.map {|a, b| "#{name.autoprefix}(#{dep.name}) #{a} #{b}" }
      end
   end

   def _files _in
      source&.spec&.files || []
   rescue
      []
   end

#   def executables
#      @executables ||= (source&.executables rescue []) || []
#   end
#
#   def docs
#      @docs ||= (source&.docs rescue []) || []
#   end
#
#   def compilables
#      @compilables ||= (source&.extensions rescue []) || []
#   end
#
   def _descriptions value_in
      source_name = of_source(:name)
      summary = of_source(:summary)

      Setup::I18n.defaulted_locales.map do |locale|
         sum = t(:"spec.rpm.#{self.kind}.description", locale: locale, binding: binding)

         [ locale, sum ]
      end.compact.map do |locale_in, summary_in|
         locale = locale_in.blank? && Setup::I18n.default_locale || locale_in
         summary = !%i(lib app).include?(self.kind) && summary_in || nil

         [ locale_in, [ summary, value_in[locale] || value_in[locale_in] ].compact.join("\n\n") ]
      end.reject { |_, d| d.blank? }.to_os
   end

   def _format_descriptions value_in
      value_in.map do |name, desc|
         tdesc = desc.gsub(/\n{2,}/, "\x1F\x1F").gsub(/\n([\*\-])/, "\x1F\\1").gsub(/\n/, "\s")
         new_desc =
            tdesc.split(/ +/).reduce([]) do |res, token|
               line = res.last
               uptoken = token.gsub(/(\n[^\-\*])/, "\n\\1").strip
               temp = [ line, uptoken ].reject { |x| x.blank? }.join(" ")

               if temp.size > 80 || !line
                  res << uptoken
               else
                  line.replace(temp)
               end

               postline = res.last.split(/\x1F/, -1)
               if postline.size > 1
                  res.last.replace(postline[0].strip)
                  res.concat(postline[1..-1].map(&:strip))
               end

               res
            end.join("\n")

         [ name, new_desc ]
      end.to_os
   end

   def _version value_in
      Gem::Version.new(value_in.to_s)
   end

   def _readme _in
      files.grep(/readme.*/i).join(" ")
   end

   def _requires value_in
      #binding.pry if !of_source(:dependencies)
      deps = value_in.map do |dep|
         if !m = dep.match(/gem\((.*)\) ([>=<]+) ([\w\d\.\-]+)/)
            dep
            # Gem::Dependency.new(m[1], Gem::Requirement.new(["#{m[2]} #{m[3]}"]), :runtime)
         end
      end.compact | dependencies

      deps.reduce([]) do |deps, dep|
         deps |
            if dep.is_a?(Gem::Dependency)
               deph = Setup::Deps.to_rpm(dep.requirement)
               deph.map {|a, b| "#{prefix}(#{dep.name}) #{a} #{b}" }
            else
               [ dep ]
            end
      end
   end

   def _provides value_in
      provides = value_in.dup
      stated_name = of_state(:name)

      if stated_name && stated_name.prefix != name.autoprefix && %i(lib app).include?(self.kind)
         # TODO optionalize defaults
         provides.unshift([ stated_name.prefix, stated_name.name ].compact.join("-") + " = %EVR")
      end

      provides
   end

   def _obsoletes value_in
      obsoletes = value_in.dup
      stated_name = of_state(:name)

      if stated_name && stated_name.prefix != name.autoprefix && %i(lib app).include?(self.kind)
         # TODO optionalize defaults
         obsoletes.unshift([ stated_name.prefix, stated_name.name ].compact.join("-") + " < %EVR")
      end

      obsoletes
   end

#   def parse_options options_in
#      options_in&.each do |name, value_in|
#         value =
#            if name == "secondaries"
#               value_in.map { |_name, sec| Secondary.new(spec: self, options: sec) }
#            else
#               ::JSON.parse value_in.to_json, object_class: OpenStruct
#            end
#
#         instance_variable_set(:"@#{name}", value)
#      end
#   end

   class << self
      def included obj
         obj::STATE.each do |name, opts|
            obj.define_method(name) { self[name] ||= read_attribute(name, opts[:seq]) || of_default(name) }
            #obj.define_method("_#{name}") { of_state[name] }
            obj.define_method("has_#{name}?") { !read_attribute(name, opts["seq"]).blank? }

         end

         %w(lib exec doc devel app).each do |name|
            obj.define_method("is_#{name}?") { self.kind.to_s == name }
         end
      end
   end
end
