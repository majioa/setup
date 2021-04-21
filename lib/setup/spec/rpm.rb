require "erb"

require 'setup/spec'

class Setup::Spec::Rpm
   attr_reader :spec, :comment
   attr_accessor :space

   autoload(:Name, 'setup/spec/rpm/name')
   autoload(:Parser, 'setup/spec/rpm/parser')
   autoload(:Secondary, 'setup/spec/rpm/secondary')

   PARTS = {
      lib: nil,
      exec: :has_executables?,
      doc: :has_docs?,
      devel: :has_devel?,
   }

   STATE = {
      name: {
         seq: %w(of_options of_state of_source of_default _name),
         default: "",
      },
      epoch: {
         seq: %w(of_options of_source of_state),
         default: nil,
      },
      version: {
         seq: %w(of_options of_source of_state _version),
         default: nil,
      },
      release: {
         seq: %w(of_options of_space of_state),
         default: "alt1",
      },
      build_arch: {
         seq: %w(of_options of_state of_source),
         default: nil,
      },
      summaries: {
         seq: %w(of_options of_state of_source of_default _summaries),
         default: ""
      },
      group: {
         seq: %w(of_options of_state of_space of_source),
         default: ->(this) { t("spec.rpm.#{this.kind}.group") },
      },
      requires: {
         seq: %w(of_options of_state of_default _requires),
         default: [],
      },
      provides: {
         seq: %w(of_options of_state of_default _provides),
         default: [],
      },
      obsoletes: {
         seq: %w(of_options of_state of_default _obsoletes),
         default: [],
      },
      conflicts: {
         seq: %w(of_options of_space of_state),
         default: [],
      },
      file_list: {
         seq: %w(of_options of_state of_source),
         default: "",
      },
      licenses: {
         seq: %w(of_options of_state _licenses),
         default: [],
      },
      uri: {
         seq: %w(of_options of_state of_source of_space),
         default: nil,
      },
      vcs: {
         seq: %w(of_options of_state of_source of_space _vcs),
         default: nil,
      },
      packager: {
         seq: %w(of_options of_space of_state),
         default: ->(this) do
            changes = this.of_space(:changes)

            OpenStruct.new(
               name: changes[0].author,
               email: changes[0].email
            )
         end
      },
      source_files: {
         seq: %w(of_options of_space of_state of_default _source_files),
         default: { "0": "%name-%version.tar" }.to_os,
      },
      patches: {
         seq: %w(of_options of_space of_state),
         default: {}.to_os,
      },
      build_requires: {
         seq: %w(of_options of_state of_default _build_requires),
         default: [],
      },
      build_pre_requires: {
         seq: %w(of_options of_space of_state of_default _build_pre_requires),
         default: [ "rpm-build-ruby" ],
      },
      changes: {
         seq: %w(of_options of_state of_source of_default _changes),
         default: ->(this) do
            version = this.version
            description = t("spec.rpm.change.new", binding: binding)
            release = "alt1"

            [ OpenStruct.new(
               date: Date.today.strftime("%a %b %d %Y"),
               author: this.packager.name,
               email: this.packager.email,
               version: version,
               release: this.release,
               description: description
            ) ]
         end,
      },
      prep: {
         seq: %w(of_options of_space of_state),
         default: "%setup",
      },
      build: {
         seq: %w(of_options of_space of_state),
         default: "%ruby_build",
      },
      install: {
         seq: %w(of_options of_space of_state),
         default: "%ruby_install",
      },
      check: {
         seq: %w(of_options of_space of_state),
         default: "%ruby_test",
      },
      secondaries: {
         seq: %w(of_options of_state of_default _secondaries),
         default: [],
      },
      context: {
         seq: %w(of_options of_state of_space),
         default: {},
      },
      comment: {
         seq: %w(of_options of_space of_state),
         default: nil,
      },
      spec_template: {
         seq: %w(of_options of_state),
         default: ->(_) { IO.read(File.join(File.dirname(__FILE__), "rpm.erb")) },
      },
      compilables: {
         seq: %w(of_options of_state of_source),
         default: [],
      },
      descriptions: {
         seq: %w(of_options of_state of_source of_default _descriptions _format_descriptions),
         default: ""
      },
      readme: {
         seq: %w(of_options of_source of_space _readme of_state),
         default: nil,
      },
      executables: {
         seq: %w(of_options of_source of_space of_state),
         default: [],
      },
      docs: {
         seq: %w(of_options _docs of_state),
         default: nil,
      },
      devel: {
         seq: %w(of_options _devel of_state),
         default: nil,
      },
      devel_requires: {
         seq: %w(of_options of_state _devel_requires),
         default: nil,
      },
      devel_sources: {
         seq: %w(of_options _devel_sources of_state),
         default: [],
      },
      files: {
         seq: %w(of_options _files of_state),
         default: []
      },
      dependencies: {
         seq: %w(of_options of_state of_source),
         default: []
      }
   }

   def draw spec = nil
      b = binding

      #binding.pry
      ERB.new(spec || spec_template, trim_mode: "<>-", eoutvar: "@spec").result(b)
   end

   include Setup::RpmSpecCore

#   def full_name
#      return @full_name if @full_name
#
#      prefix = space.main_source&.respond_to?(:name_prefix) && space.main_source.name_prefix || nil
#      pre_name = [ prefix, space.main_source&.name || space.name ].compact.join("-")
#      @full_name = !pre_name.blank? && pre_name || self["adopted_name"]
#   end

#   def has_any_compilable?
#      !space.compilables.empty?
#   end
#
#   # properties
#
   def macros name
      [ context.__macros[name] ].flatten(1).map { |x| "%#{name} #{x}" }.join("\n")
   end

   def variables
      vars = context.dup
      vars.__macros = nil
      vars.delete_field("__macros")
      vars
   end

   def _secondaries value_in
      names = value_in.map { |x| x.name }

      secondaries = space.sources.reject do |source|
         source.name == space.main_source&.name
      end.map do |source|
         sec = Secondary.new(source: source, spec: self, options: { name_prefix: name.prefix })

         secondary_parts_for(sec, source)
      end.concat(secondary_parts_for(self, source)).flatten.compact

      secondaries = secondaries.map do |sec|
         if presec = names.delete(sec.name)
            of_state(:secondaries).find do |osec|
               osec.name == presec
            end.resourced_from(sec)
         else
            sec
         end
      end

      secondaries | names.map do |an|
         value_in.find {|sec| sec.name == an } ||
            Secondary.new(spec: self,
                          kind: an.kind,
                          options: { name: an.fullname })
      end
   end

   def is_same_source? source
      source && self.source == source
   end

   protected

   def _build_requires value_in
      deps = value_in.map do |dep|
         if !m = dep.match(/gem\((.*)\) ([>=<]+) ([\w\d\.\-]+)/)
            dep
            #Gem::Dependency.new(m[1], Gem::Requirement.new(["#{m[2]} #{m[3]}"]), :runtime)
         end
      end.compact | of_space(:dependencies)

      #binding.pry
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

   def _vcs value_in
      vcs = URL_MATCHER.reduce(value_in) do |res, (rule, e)|
         res || uri && (match = uri.match(rule)) && e[match] || nil
      end

      vcs && "#{vcs}#{/\.git/ !~ vcs && ".git" || ""}" || nil
   end

   def _source_files value_in
      source_files = value_in.dup
      defaults = of_default(:source_files)[:"0"]

      source_files[:"0"] = defaults if source_files[:"0"] != defaults

      source_files
   end

   def _build_pre_requires value_in
      build_pre_requires = value_in.dup || []
      stated_name = of_state(:name)

      if stated_name && stated_name.prefix != name.autoprefix
         build_pre_requires.unshift(of_default(:build_pre_requires)[0])
      end

      build_pre_requires
   end

   def _licenses value_in
      sources = of_space(:valid_sources) || []
      list = sources.map do |source|
            source.licenses rescue nil
         end.compact.flatten.uniq

      list.blank? && value_in || list
   end

   def _changes value_in
      new_change =
         if of_state(:version) && version != of_state(:version)
            # TODO move to i18n and settings file
            previous_version = of_state(:version)
            version = self.version
            description = t("spec.rpm.change.upgrade", binding: binding)
            release = "alt1"

            OpenStruct.new(
               date: Date.today.strftime("%a %b %d %Y"),
               author: packager.name,
               email: packager.email,
               version: version,
               release: release,
               description: description
            )
         end

      value_in | [ new_change ].compact
   end

   def secondary_parts_for object, source
      PARTS.map do |(kind, func)|
         next object.is_a?(Secondary) && object || nil if !func

         if object.send(func)
            Secondary.new(source: source, spec: self, kind: kind, options: { name_prefix: name.prefix })
         end
      end
   end

   def source
      space.main_source
   end

   def kind
      @kind ||= source.is_a?(Setup::Source::Gem) && :lib || :app
   end

   def initialize space: nil, state: {}, options: {}
      @space = space
      @state = state
      @options = options
   end

   class << self
      def match? source_in
         Parser.match?(source_in)
      end

      def parse source_in
         Parser.new.parse(source_in)
      end

      def draw space, spec_in = nil
         spec = space.spec || self.new(space: space)
         spec.draw(spec_in)
      end
   end
end
