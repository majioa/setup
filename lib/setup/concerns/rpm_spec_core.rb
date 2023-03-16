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

   def of_source name
      source.send(name) || nil
   rescue NameError
      nil
   end

   def of_state name
      state[name.to_s] || state[name.to_sym]
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
       # binding.pry if name == :context
         if func[0] == "_"
            send(func, value_in)
         elsif value_in.blank?
            send(func, name)
         else
            value_in
         end
      end
      # binding.pry if name == :context
      aa
   end

   def options= options
      @options = options.to_os
   end

   def options
      @options ||= {}.to_os
   end

   def state
      @state ||= {}.to_os
   end

   def state= value
      if value.name
         @name = name.merge(value.name)
      end

      @state = value.to_os
   end

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
            max = executables.map { |x| x.size }.max
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

      (name, aliases) =
         if is_exec? && executable_name.size >= 3
            [ executable_name, executables ]
         elsif executable_name.size < 3
            [ value_in, executables ]
         else
            [ value_in, [] ]
         end

      Setup::Spec::Rpm::Name.parse(name, kind: kind, prefix: options[:name_prefix], aliases: aliases)
   end

   def _devel _in = nil
      dependencies | devel_sources
   end

   def _devel_sources _in = nil
      files.grep(/.*\.h(pp)?$/)
   end

   def _docs _in = nil
      of_source(:docs) || of_default(:docs)
   end

   def _summaries value_in
      source_name = source&.name
      summaries_in = @host && host.summaries || of_source(:summaries) || {}.to_os

      Setup::I18n.locales.map do |locale_in|
         locale = locale_in.blank? && Setup::I18n.default_locale || locale_in
         summary_pre = !%i(lib app).include?(self.kind) && summaries_in[locale_in] || value_in[locale] || value_in[locale_in] || nil
         summary = summary_pre&.match("(.*?)[\-\.,_\s]*?$")&.[](1)

         [ locale_in, t(:"spec.rpm.#{self.kind}.summary", locale: locale, binding: binding) ]
      end.to_os.compact
   end

   def _devel_requires value_in
      value_tmp = value_in || source&.dependencies(:development) || []
      deps_versioned = replace_versioning(value_tmp)

      render_deps(append_versioning(deps_versioned))
   end

   def _devel_conflicts value_in
      value_tmp = value_in || source&.dependencies(:development) || []
      deps_versioned = replace_versioning(value_tmp)

      render_deps(append_versioning(deps_versioned), :negate)
   end

   def _files _in
      source&.spec&.files || []
   rescue
      []
   end

   def _proceed_description value_in
      value_in.map { |_locale, desc| desc.is_a?(Array) ? desc.join("\n") : desc }
   end

   def _descriptions value_in
      source_name = of_source(:name)
      summary = of_source(:summary)&.match("(.*?)[\.,-_\s]+$")&.[](1) # NOTE required for eval
      summaries_in = @host && summaries || { Setup::I18n.default_locale => summary }
      descriptions_in = @host && host.descriptions || of_source(:descriptions) || of_source(:summaries) || {}.to_os

      Setup::I18n.locales.map do |locale|
         sum = t(:"spec.rpm.#{self.kind}.description", locale: locale, binding: binding)

         [ locale, sum ]
      end.to_os.map do |locale_in, summary_in|
         if locale_in.to_s == Setup::I18n.default_locale
            if !%i(lib app).include?(self.kind)
               summary_in = summaries_in[locale_in]
               first = summary_in && (summary_in + ".")
               rest_in = descriptions_in[locale_in]
               /(?<re>.*)\.$/ =~ rest_in
               rest = first&.include?(re || rest_in || "") ? nil : rest_in
               [ first, rest ].compact.join("\n\n")
            else
               value_in[locale_in] || descriptions_in[locale_in]
            end
         else
            summary_in = summaries_in[locale_in]
            /(?<s>.+)\.?$/ =~ summary_in && s && "#{s}." || value_in[locale_in]
         end
      end.compact
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

         new_desc
      end
   end

   def _version value_in
      reversion = gem_versionings.select {|n,v| name.eql?(n, true) }.to_h.values.first
      value = reversion || value_in

      case value
      when Gem::Version
         value
      when Gem::Dependency
         value.requirement.requirements.first.last
      when Array
         Gem::Version.new(value.first.to_s)
      else
         Gem::Version.new(value.to_s)
      end
   end

   def _readme _in
      files.grep(/(readme|чтимя).*/i).group_by {|x| File.basename(x) }.map {|(name, a)| a.first }.join(" ")
   end

   def _requires_plain_only value_in
      @requires_plain_only ||= value_in&.reject {|dep| dep.match(/gem\((.*)\) ([>=<]+) ([\w\d\.\-]+)/) }
   end

   def _conflicts_plain_only value_in
      @conflicts_plain_only ||= value_in&.reject {|dep| dep.match(/gem\((.*)\) ([>=<]+) ([\w\d\.\-]+)/) }
   end

   def _pre_name value_in
      return value_in if value_in.is_a?(Setup::Spec::Rpm::Name)

      name = @name ||
         of_options(:name) ||
         of_state(:name) ||
         rootdir && rootdir.split("/").last ||
         value_in

      if name.is_a?(Setup::Spec::Rpm::Name)
         name
      else
         Setup::Spec::Rpm::Name.parse(name, prefix: options[:name_prefix])
      end
   end

   def _requires value_in
      deps_pre =
         if %i(lib app).include?(self.kind)
            source&.dependencies(:runtime) || []
         else
            reqs = self.kind == :devel && devel_requires || []
            [ provide_dep ].compact | reqs
         end

      deps = replace_versioning(deps_pre | value_in)

      render_deps(deps)
   end

   def _conflicts value_in
      deps_pre =
         if %i(lib app).include?(self.kind)
            source&.dependencies(:runtime) || []
         else
            reqs = self.kind == :devel && devel_conflicts || []
         end

      deps = replace_versioning(deps_pre | value_in)

      render_deps(deps, :negate)
   end

   #
   def replace_versioning deps_in
      versioning_list = available_gem_ranges.merge(gem_versionings)

      deps_in.map do |dep_in|
         if dep_in.is_a?(Gem::Dependency) && provide_dep.name != dep_in.name
            dep = versioning_list[dep_in.name]

            if dep
               combine_deps(dep_in, dep)
            else
               dep_in
            end
         else
            dep_in
         end
      end
   end

   # +combine_deps+ method combines dependenies' requirements passed with arguments +base_dep+, and +dep+ base on
   # the operators in +base_dep+
   # Example:
   #    combine_deps(base_dep, dep)
   #
   def combine_deps base_dep, dep
      dep_ver = Gem::Dependency.new(base_dep.name, base_dep.requirement | dep.requirement)
      ops = base_dep.requirement.requirements.map {|x| x.first }.join(" ").gsub(/\A(~>|=)\z/, ">= < =").split(" ").uniq
      reqs = dep_ver.requirement.requirements.select {|x| ops.include?(x[0]) }

      dep_ver.requirement.requirements.replace(reqs)

      dep_ver
   end

   def append_versioning deps_in
      gem_versionings.reduce(deps_in) do |deps, name, dep|
         index = deps.index { |dep_in| dep_in.is_a?(Gem::Dependency) && dep_in.name == name.to_s }

         #binding.pry
         index && deps || deps | [ dep ]
      end
   end

   def variables
      @variables ||= context.__macros || {}.to_os
   end

   def render_deps deps_in, mode = :debound
      func = mode == :debound ? :lower_to_rpm : :upper_negate_to_rpm

      deps_in.reduce([]) do |deps, dep|
         deps |
            if dep.is_a?(Gem::Dependency)
               deph = Setup::Deps.send(func, dep.requirement)

               deph.blank? ? [] : ["#{prefix}(#{dep.name}) #{deph.first} #{deph.last}"]
            else
               name = Setup::Spec::Rpm::Name.parse(dep)
               deps_in.find do |dep_in|
                  if dep_in.is_a?(Gem::Dependency)
                     dep_in.name == name.name
                  end
               end && [] || [ dep ]
            end
      end
   end

   def provide_dep
      gem_versionings.select {|n,v| name.eql?(n, true) }.to_h.values.first || source&.provide
   end

   def _provides value_in
      stated_name = of_state(:name)
      #binding.pry

      provides =
         if stated_name && stated_name.prefix != name.autoprefix && %i(lib app).include?(self.kind)
            # TODO optionalize defaults
            [[ stated_name.prefix, stated_name.name ].compact.join("-") + " = %EVR"]
         else
            []
         end | value_in

      provides |
         case self.kind
         when :lib
            render_deps([provide_dep])
         when :app
            [[ "ruby", name ].join("-")]
         else
            []
         end
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

   def _available_gem_list value_in
      value_in || options.available_gem_list || of_default(:available_gem_list)
   end

   def _available_gem_ranges value_in
      available_gem_list.reduce({}.to_os) do |res, (name, version_in)|
         low = [ version_in ].flatten.map {|v| Gem::Version.new(v) }.min
         bottom = [ version_in ].flatten.map {|v| Gem::Version.new(v.split(".")[0..1].join(".")).bump }.max
         reqs = [ ">= #{low}", "< #{bottom}" ]

         res[name] = Gem::Dependency.new(name, Gem::Requirement.new(reqs))

         res
      end
   end

   def dep_list_merge first_in, second_in
      first = first_in || {}.to_os
      second = second_in || {}.to_os
      a=
      first.reduce(second) do |r, name, req|
         if r[name]
            r[name] = r[name].merge(req)

            r
         else
            r.merge({ name => req }.to_os)
         end
      end
         #binding.pry
         a
   end

   def dep_list_intersect *lists_in
      lists = lists_in.map {|list| list.to_os }

      lists.reduce do |r_list, list|
         list.reduce(r_list) do |r, name, req|
            if r[name]
               r[name] = Gem::Dependency.new("rake", req.requirement | r[name].requirement)

               r
            else
               r.merge({ name => req }.to_os)
            end
         end
      end
   end

   def _gem_versionings value_in
      pre_vers =
      [ variables.gem_replace_version ].flatten.compact.reduce({}.to_os) do |res, gemver|
         /^(?<name>[^\s]+)(?:\s(?<rel>[<=>~]+)\s(?<version>[^\s]+))?/ =~ gemver

         if res[name]
            res[name].requirement.requirements << [rel, Gem::Version.new(version)]
         else
            res[name] = Gem::Dependency.new(name, Gem::Requirement.new(["#{rel} #{version}"]))
         end

         res
      end

      dep_list_merge(value_in, pre_vers)
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
