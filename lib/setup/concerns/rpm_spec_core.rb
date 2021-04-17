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

#   def adopted_name
#      autoname.adopted_name
#   end
#
   def _name value_in
      #adopted_name = self["adopted_name"] || full_name&.gsub(/[_\.]/, '-')
      #adopted_name = self["adopted_name"] || full_name&.gsub(/[_\.]/, '-')

      if value_in.is_a?(Setup::Spec::Rpm::Name)
         value_in
      else
         #binding.pry
         Setup::Spec::Rpm::Name.parse(value_in, kind: @kind)
      end
   end

#   def _adopted_name
#      @adopted_name
#   end
#
#   def has_vcs?
#      !vcs.blank?
#   end
#
#   def has_compilable?
#      !compilables.empty?
#   end
#
#   def has_comment?
#      !comment.blank?
#   end
#
#   def has_executable?
#      !executables.empty?
#   end
#
#   def has_readme?
#      !readme.blank?
#   end
#
#   def has_docs?
#      !docs.empty?
#   end
#
   def _devel _in = nil
      source.respond_to?(:dependencies) && source.dependencies || devel_sources
   end

   def _devel_sources _in = nil
      files.grep(/.*\.h/)
   end

   def _docs _in = nil
      source.docs || []
   end

   def _summaries value_in
      if value_in.is_a?(Array)
         value_in.map { |v| [ "", v ] }.to_os
      else
         value_in
      end
   end

#   def vcs
#      return @_vcs if @_vcs
#
#      vcs = URL_MATCHER.reduce(read_attribute(:vcs)) do |res, (rule, e)|
#         res || uri && (match = uri.match(rule)) && e[match] || nil
#      end
#
#      @_vcs = vcs && "#{vcs}#{/\.git/ !~ vcs && ".git" || ""}" || nil
#   end
#
#   def devel_deps
#      return @devel_deps if @devel_deps
#
#      dep_list = source.dependencies.reduce([]) do |deps, dep|
#         deph = Setup::Deps.to_rpm(dep.requirement)
#         deps | deph.map {|a, b| "#{prefix}(#{dep.name}) #{a} #{b}" }
#      end.map.with_index { |v, i| [ "#{i}", v ] }.to_h
#
#      @devel_deps = eval(dep_list)
#   end
#
#   def files
#      @files ||= (source&.files rescue []) || []
#   end
#
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

#   def readme
#      files.grep(/readme.*/i).join(" ")
#   end
#
#   # +executable_name+ returns a name of the executable package, based on
#   # the all the sources executables.
#   #
#   # spec.executable_name # => foo
#   #
#   def executable_name
#      # TODO make smart selection of executable name
#      executables.first&.gsub(/[_\.]/, '-')
#   end
#
#   def [] name
#      value = instance_variable_get(:"@#{name}")
#      value && eval(value)
#   end
#
#   def prefix
#      autoname.default_prefix
#   end
#
#   def eval value_in
#      if value_in.is_a?(String)
#         value_in.gsub(/%[{\w}]+/) do |match|
#            /%(?:{(?<m>\w+)}|(?<m>\w+))/ =~ match
#            context[m]
#         end
#      else
#         value_in
#      end
#   end
#
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
      end
   end
end
