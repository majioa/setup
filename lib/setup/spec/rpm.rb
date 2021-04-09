require "erb"

require 'setup/spec'

class Setup::Spec::Rpm
   attr_reader :home, :spec, :comment
   attr_accessor :space

   FIELDS = {
      name: nil,
      epoch: nil,
      version: nil,
      release: "alt1",
      build_arch: nil,
      summaries: {},
      group: nil,
      requires: {},
      provides: {},
      obsoletes: {},
      conflicts: {},
      descriptions: {},
      file_list: nil,
   }

   ONLY_FIELDS = {
      licenses: [],
      uri: nil,
      vcs: nil,
      packager: ->(this) { [ this.changes[0].author, "<#{this.changes[0].email}>" ].join(" ") },
      source_files: OpenStruct.new("0": "%name-%version.tar"),
      patches: {},
      build_requires: ->(this) { this.dependencies },
      build_pre_requires: OpenStruct.new("0": "rpm-build-ruby"),
      changes: [],
      prep: nil,
      build: nil,
      install: nil,
      check: nil,
      secondaries: {},
      context: nil,
   }

   module CPkg
      def summary
         summaries[""]
      end

      def adopted_name
         self["adopted_name"] || full_name&.gsub(/[_\.]/, '-')
      end

      def _adopted_name
         @adopted_name
      end

      def has_compilable?
         !compilables.empty?
      end

      def has_comment?
         !comment.blank?
      end

      def has_executable?
         !executables.empty?
      end

      def has_readme?
         !readme.blank?
      end

      def has_doc?
         !docs.empty?
      end

      def has_devel?
         source.respond_to?(:dependencies) && !source.dependencies.empty? || has_devel_sources?
      end

      def has_devel_sources?
         !files.grep(/.*\.h/).empty?
      end

      def devel_deps
         return @devel_deps if @devel_deps

         dep_list = source.dependencies.reduce([]) do |deps, dep|
            deph = Setup::Deps.to_rpm(dep.requirement)
            deps | deph.map {|a, b| "#{prefix}(#{dep.name}) #{a} #{b}" }
         end.map.with_index { |v, i| [ "#{i}", v ] }.to_h

         @devel_deps = eval(dep_list)
      end

      def files
         @files ||= (source&.files rescue []) || []
      end

      def executables
         @executables ||= (source&.executables rescue []) || []
      end

      def docs
         @docs ||= (source&.docs rescue []) || []
      end

      def compilables
         @compilables ||= (source&.extensions rescue []) || []
      end

      def readme
         files.grep(/readme.*/i).join(" ")
      end

      # +executable_name+ returns a name of the executable package, based on
      # the all the sources executables.
      #
      # spec.executable_name # => foo
      #
      def executable_name
         # TODO make smart selection of executable name
         executables.first&.gsub(/[_\.]/, '-')
      end

      def [] name
         value = instance_variable_get(:"@#{name}")
         value && eval(value)
      end

      def prefix
         "gem"
      end

      def eval value_in
         if value_in.is_a?(String)
            value_in.gsub(/%[{\w}]+/) do |match|
               /%(?:{(?<m>\w+)}|(?<m>\w+))/ =~ match
               self["context"][m]
            end
         else
            value_in
         end
      end

      def parse_options options_in
         options_in&.each do |name, value_in|
            value =
               if name == "secondaries"
                  value_in.map { |_name, sec| Secondary.new(spec: self, options: sec) }
               else
                  JSON.parse value_in.to_json, object_class: OpenStruct
               end

            instance_variable_set(:"@#{name}", value)
         end
      end
   end

   class Secondary
      attr_reader :source, :spec

      include CPkg

      FIELDS.each do |name, default|
         define_method(name) do
            # binding.pry if name == :name
            self[name.to_s] ||
               source.respond_to?(name) && source.send(name) ||
               default.is_a?(Proc) && default[self] ||
               default
         end
         define_method("_#{name}") { instance_variable_get(:"@#{name}") }
         define_method("has_#{name}?") { !!instance_variable_get(:"@#{name}")}
      end

      def summaries
         return @summaries if @summaries

         if !summaries = self["summaries"]
            summaries =
               if default_summary = source.summary rescue nil
                  OpenStruct.new("" => default_summary)
               else
                  {}.to_os
               end
         end

         @summaries = summaries
      end

      def full_name
         return @full_name if @full_name

         prefix = source.respond_to?(:name_prefix) && source.name_prefix || nil
         pre_name = [ prefix, source.name ].compact.join("-")
         @full_name = !pre_name.blank? && pre_name || spec["adopted_name"]
      end

      def options= value
         parse_options(value)
      end

      def initialize spec: raise, source: nil, options: {}
         @source = source
         @spec = spec
         parse_options(options)
      end
   end

   MATCHER = /^Name:\s+([^\s]+)/i

   SCHEME = {
      adopted_name: /^Name:\s+([^\s]+)/i,
      version: /Version:\s+([^\s]+)/i,
      epoch: /Epoch:\s+([^\s]+)/i,
      release: /Release:\s+([^\s]+)/i,
      summaries: {
         regexp: /Summary(?:\(([^\s:]+)\))?:\s+([^\s].+)/i,
         parse_func: :parse_summary
      },
      licenses: {
         non_contexted: true,
         regexp: /License:\s+([^\s].+)/i,
         parse_func: :parse_license
      },
      group: /Group:\s+([^\s]+)/i,
      uri: /Url:\s+([^\s]+)/i,
      vcs: /Vcs:\s+([^\s]+)/i,
      packager: /Packager:\s+([^\s].+)/i,
      build_arch: /BuildArch:\s+([^\s]+)/i,
      patches: {
         non_contexted: true,
         regexp: /Patch(\d+)?:\s+([^\s]+)/i,
         parse_func: :parse_file
      },
      source_files: {
         non_contexted: true,
         regexp: /Source(\d+)?:\s+([^\s]+)/i,
         parse_func: :parse_file
      },
      build_pre_requires: {
         non_contexted: true,
         regexp: /(?:BuildPreReq|BuildRequires\(pre\)):\s+([\w\s<=>\.]+)/i,
         parse_func: :parse_dep
      },
      build_requires: {
         non_contexted: true,
         regexp: /BuildRequires:\s+([\w\s<=>\.]+)/i,
         parse_func: :parse_dep
      },
      obsoletes: {
         regexp: /Obsoletes:\s+([\w\s<=>\.]+)/i,
         parse_func: :parse_dep
      },
      provides: {
         regexp: /Provides:\s+([\w\s<=>\.]+)/i,
         parse_func: :parse_dep
      },
      requires: {
         regexp: /Requires:\s+([\w\s<=>\.]+)/i,
         parse_func: :parse_dep
      },
      conflicts: {
         regexp: /Conflicts:\s+([\w\s<=>\.]+)/i,
         parse_func: :parse_dep
      },
      descriptions: {
         regexp: /%description\s*([^\s].*)?/i,
         parse_func: :parse_description
      },
      secondaries: {
         non_contexted: true,
         regexp: /%package\s+(.+)/i,
         parse_func: :parse_secondary
      },
      prep: {
         non_contexted: true,
         regexp: /%prep/i,
         parse_func: :parse_plain_section
      },
      build: {
         non_contexted: true,
         regexp: /%build/i,
         parse_func: :parse_plain_section
      },
      install: {
         non_contexted: true,
         regexp: /%install/i,
         parse_func: :parse_plain_section
      },
      check: {
         non_contexted: true,
         regexp: /%check/i,
         parse_func: :parse_plain_section
      },
      file_list: {
         regexp: /%files\s*([^\s].*)?/i,
         parse_func: :parse_file_list
      },
      changes: {
         non_contexted: true,
         regexp: /%changelog/i,
         parse_func: :parse_changes
      },
      context: {
         non_contexted: true,
         regexp: /^%(?:(?:define|global)|([^\s]+))\s+(?:([^\s]+)\s+([^\s].*)|(.*))/i,
         parse_func: :parse_context
      }
   }

   @@spec = IO.read("lib/setup/spec/rpm.erb")

   def draw spec = nil
      b = binding

      #binding.pry
      ERB.new(spec || @@spec, trim_mode: "<>-", eoutvar: "@spec").result(b)
   end

   include CPkg

   FIELDS.merge(ONLY_FIELDS).each do |name, default|
      define_method(name) do
         #binding.pry if name == :licenses
         self[name.to_s] ||
            space.respond_to?(name) && space.send(name) ||
            (space.main_source.send(name) rescue nil) ||
            default.is_a?(Proc) && default[self] ||
            default
      end
      define_method("_#{name}") { instance_variable_get(:"@#{name}") }
      define_method("has_#{name}?") { !!instance_variable_get(:"@#{name}") }
   end

   def adopted_name
      super
   end

   def full_name
      return @full_name if @full_name

      prefix = space.main_source&.respond_to?(:name_prefix) && space.main_source.name_prefix || nil
      pre_name = [ prefix, space.main_source&.name || space.name ].compact.join("-")
      @full_name = !pre_name.blank? && pre_name || self["adopted_name"]
   end

   def has_any_compilable?
      !space.compilables.empty?
   end

   # properties

   def dependencies
      return @dependencies if @dependencies

      dep_list =
      space.dependencies.reduce([]) do |deps, dep|
         deph = Setup::Deps.to_rpm(dep.requirement)
         deps | deph.map {|a, b| "#{prefix}(#{dep.name}) #{a} #{b}" }
      end.map.with_index { |v, i| [ "#{i}", v ] }.to_h

      @dependencies = eval(dep_list)
   end

   def macros name
      [ self["context"].__macros[name] ].flatten(1).map { |x| "%#{name} #{x}" }.join("\n")
   end

   def variables
      vars = self["context"]
      vars.__macros = nil
      vars.delete_field("__macros")
      vars
   end

   def secondaries
      return @secondaries if @secondaries

      adopted_names = self["secondaries"].to_h.keys.map(&:to_s)

      secondaries = space.sources.reject do |source|
         source.name == space.main_source&.name
      end.map do |source|
         sec = Secondary.new(source: source, spec: self)

         if adopted_names.delete(sec.adopted_name)
            sec.options = secondaries[sec.adopted_name]
         end

         sec
      end

      @secondaries = secondaries | adopted_names.map do |an|
         Secondary.new(spec: self, options: secondaries[an])
      end
   end

   protected

   def source
      space.main_source
   end

   def initialize space: nil, home: ENV['GEM_HOME'] || ::Gem.paths.home, options: nil
      @space = space
      @home = home
      parse_options(options)
   end

   class << self
      def draw space, spec_in = nil
         spec = space.spec || self.new(space: space)
         spec.draw(spec_in)
      end

      def source source_in
         if source_in.respond_to?(:readlines)
            source_in.rewind
            source_in.readlines
         else
            source_in.split("\n")
         end
      end

      def match? source_in
         MATCHER =~ source(source_in).join("\n")
      end

      def parse source_in
         context = {}
         matched = {}
         match = nil

         opts = source(source_in).reduce({}) do |opts, line|
            SCHEME.find do |(key, rule)|
               match = rule.is_a?(Regexp) && rule.match(line) ||
                       rule.is_a?(Hash) && rule[:regexp].match(line)

               # binding.pry
               if match
                  if matched[:name]
                     if matched[:name] != key
                        store_value(opts, matched[:match], matched[:name], matched[:flow], context)
                        matched = { name: key.to_s, flow: "", match: match }
                     end
                  else
                     matched = { name: key.to_s, flow: "", match: match }
                  end
               end
            end

            if matched
               matched[:flow].concat(line)
            end

            opts
         end

         # binding.pry
         store_value(opts, matched[:match], matched[:name], matched[:flow], context)

         self.new(options: opts)
      end

      def store_value opts, match, key, flow, context
         data = SCHEME[key.to_sym]
         rule = data.is_a?(Hash) && data[:rule] || data
         parse_func = data.is_a?(Hash) && data[:parse_func] || :parse_default
         non_contexted = data.is_a?(Hash) && data[:non_contexted]
         value = method(parse_func)[match, flow, opts, context]
         copts = !non_contexted && context[:name] && opts["secondaries"][context[:name]] || opts
         # binding.pry

         copts[key] =
         case copts[key]
         when NilClass
            value
         when Array
            copts[key].concat(value)
         when Hash
            copts[key].deep_merge(value)
         else
            [ copts[key], value ]
         end

         opts
      end

      def parse_file match, *_
         { match[1] || "0" => match[2] }
      end

      def parse_file_list match, flow, opts, context
         context.replace(parse_context_line(match[1], opts))
         flow.split("\n")[1..-1].join("\n")
      end

      def parse_changes _, flow, *_
         rows = flow.split("* ").map { |p| p.strip }.compact.map { |p| p.split("\n") }

         rows[1..-1].map do |row|
            /(?<date>^\w+\s+\w+\s+\w+\s+\w+)\s+(?<author>.*)\s*(?:<(?<email>.*)>)\s+(?<version>[\w\.]+)(?:-(?<release>\w+))?$/ =~ row[0]

            {
               date: date,
               author: author.strip,
               email: email,
               version: version,
               release: release,
               description: row[1..-1].join("\n")
            }
         end.reverse
      end

      def parse_dep match, *_
         match[1].scan(/\w+(?:\s+[<=>]+\s+[\d\.]+)?/)
      end

      def parse_default match, *_
         match[1]
      end

      def parse_plain_section _, flow, *_
         flow.split("\n")[1..-1].join("\n")
      end

      def parse_secondary match, flow, opts, context
         context.replace(parse_context_line(match[1], opts))
         { context[:name] => { "adopted_name" => context[:name] }}
      end

      def parse_description match, flow, opts, context
         context.replace(parse_context_line(match[1], opts))
         { context[:cp] => flow.split("\n")[1..-1].join("\n") }
      end

      def parse_license match, *_
         match[1].split(/(?: or |\/)/).map(&:strip)
      end

      def parse_summary match, *_
         { match[1] => match[2] }
      end

      def parse_context match, *_
         if match[1]
            { "__macros" => { match[1] => match[4] || "#{match[2]} #{match[3]}" }}
         else
            { match[2] => match[3] }
         end
      end

      def parse_context_line line, opts
         key = nil
         context = line.to_s.split(/\s+/).reduce({}) do |res, arg|
            case arg
            when '-l'
               key = :cp
            when '-n'
               key = :fullname
            else
               case key
               when :cp
                  res[:cp] = arg
               when :fullname
                  res[:name] = arg
               else
                  res[:name] = "#{opts["adopted_name"]}-#{arg}"
               end
            end

            res
         end

         if context[:name]
            opts["secondaries"] ||= {}
            opts["secondaries"][context[:name]] ||= {}
         end

         context
      end
   end
end
