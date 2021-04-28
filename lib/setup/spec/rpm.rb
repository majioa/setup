require "erb"

require 'setup/spec'

class Setup::Spec::Rpm
   attr_reader :spec, :comment
   attr_accessor :space

   %w(Name Parser Secondary).reduce({}) do |types, name|
      autoload(:"#{name}", File.dirname(__FILE__) + "/rpm/#{name.downcase}")
   end

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
         seq: %w(of_options of_state _release),
         default: "alt1",
      },
      build_arch: {
         seq: %w(of_options of_state of_source),
         default: "noarch",
      },
      summaries: {
         seq: %w(of_options of_state of_source of_default _summaries),
         default: ""
      },
      group: {
         seq: %w(of_options of_state of_source),
         default: ->(this) { t("spec.rpm.#{this.kind}.group") },
      },
      requires: {
         seq: %w(of_options of_state of_default _requires_plain_only _requires),
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
         seq: %w(of_options of_state),
         default: ->(this) do
            OpenStruct.new(
               name: this.space.options.maintainer_name || "Spec Author",
               email: this.space.options.maintainer_email || "author@example.org"
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
            release = this.of_options(:release) || this.of_state(:release) || "alt1"
               #author: this.space.options.maintainer_name || "Spec Author",
               #email: this.space.options.maintainer_email || "author@example.org",

            [ OpenStruct.new(
               date: Date.today.strftime("%a %b %d %Y"),
               author: this.packager.name,
               email: this.packager.email,
               version: version,
               release: release,
               description: description) ]
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
         default: {}.to_os
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
      },
      ruby_alias_names: {
         seq: %w(of_options of_state _ruby_alias_names _ruby_alias_names_local),
         default: []
      },
      gem_versionings: {
         seq: %w(of_options of_state _gem_versionings),
         default: []
      },
      ignored_names: {
         seq: %w(of_options of_state of_space),
         default: []
      }
   }

   include Setup::RpmSpecCore

   def draw spec = nil
      b = binding

      #binding.pry
      ERB.new(spec || spec_template, trim_mode: "<>-", eoutvar: "@spec").result(b)
   end

   def macros name
      [ context.__macros[name] ].flatten(1).map { |x| "%#{name} #{x}" }.join("\n")
   end

   def is_same_source? source
      source && self.source == source
   end

   def kind
      @kind ||= source.is_a?(Setup::Source::Gem) && :lib || :app
   end

   protected

   def ruby_build
      @ruby_build ||= variables.ruby_build&.split(/\s+/) || []
   end

   def _ruby_alias_names value_in
      @ruby_alias_names ||= (value_in || []) | ruby_build.reduce([]) do |res, line|
         case line
         when /--use=(.*)/
            res << [ $1 ]
         when /--alias=(.*)/
            res.last << $1
         end

         res
      end
   end

   def _ruby_alias_names_local value_in
      return @ruby_alias_names_local if @ruby_alias_names_local

      names = [ source&.name, name&.name ].compact.uniq

      @ruby_alias_names_local = value_in | (names.size > 1 && [ names ] || [])
   end

   def _secondaries value_in
      names = value_in.map { |x| x.name }

      secondaries = space.sources.reject do |source|
         source.name == space.main_source&.name ||
            ignored_names.include?(source.name)
      end.map do |source|
         sec = Secondary.new(source: source,
                             spec: self,
                             state: { context: context },
                             options: { name_prefix: name.prefix })

         secondary_parts_for(sec, source)
      end.concat(secondary_parts_for(self, source)).flatten.compact

      secondaries = secondaries.map do |sec|
         if presec = names.delete(sec.name)
            sub_sec = of_state(:secondaries).find do |osec|
               osec.name == presec
            end

            if sub_sec.is_a?(Secondary)
               sub_sec.resourced_from(sec)
            elsif sub_sec.is_a?(OpenStruct)
               sec.state = sub_sec
               sec
            end
         else
            sec
         end
      end

      secondaries | names.map do |an|
         sec = value_in.find { |sec| sec.name == an }

         if sec.is_a?(Secondary)
            sec
         else
            source = space.sources.find { |s| s.name = an.autoname }
            name = Setup::Spec::Rpm::Name.parse(an.fullname)

            Secondary.new(spec: self,
                          kind: an.kind,
                          state: sec,
                          source: source,
                          options: { name: name })
         end
      end
   end

   def _build_requires value_in
      deps_pre = value_in.map do |dep|
         if !m = dep.match(/gem\((.*)\) ([>=<]+) ([\w\d\.\-]+)/)
            dep
            #Gem::Dependency.new(m[1], Gem::Requirement.new(["#{m[2]} #{m[3]}"]), :runtime)
         end
      end.compact | of_space(:dependencies)

      #TODO
      deps_pre -= ["ruby-tool-setup"]
      #binding.pry
      apply_versioning(deps_pre).reduce([]) do |deps, dep|
         deps |
            if dep.is_a?(Gem::Dependency)
               deph = Setup::Deps.to_rpm(dep.requirement)

               [ deph.map {|a, b| "#{prefix}(#{dep.name}) #{a} #{b}" }.join(" ") ]
            else
               name = Setup::Spec::Rpm::Name.parse(dep)
               deps_pre.find do |dep_pre|
                  if dep_pre.is_a?(Gem::Dependency)
                     dep_pre.name == name.name
                  end
               end && [] || [ dep ]
            end
      end
   end

   def _vcs value_in
      vcs = URL_MATCHER.reduce(value_in) do |res, (rule, e)|
         res || uri && (match = uri.match(rule)) && e[match] || nil
      end

      vcs && "#{vcs}#{/\.git/ !~ vcs && ".git" || ""}".downcase || nil
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
         default = of_default(:build_pre_requires)[0]

         build_pre_requires.unshift(default) unless build_pre_requires.include?(default)
      end

      build_pre_requires
   end

   def _licenses value_in
      sources = of_space(:valid_sources) || []
      list = sources.map do |source|
            source.licenses
         end.flatten.uniq

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
            packager_name = space.options.maintainer_name || packager.name
            packager_email = space.options.maintainer_email || packager.email

            OpenStruct.new(
               date: Date.today.strftime("%a %b %d %Y"),
               author: packager_name,
               email: packager_email,
               version: version,
               release: release,
               description: description
            )
         end

      value_in | [ new_change ].compact
   end

   def _release value_in
      changes.last.release
   end

   def secondary_parts_for object, source
      PARTS.map do |(kind, func)|
         next object.is_a?(Secondary) && object || nil if !func

         if object.send(func)
            Secondary.new(source: source,
                          spec: self,
                          kind: kind,
                          state: { context: context },
                          options: { name_prefix: name.prefix })
         end
      end
   end

   def source
      space.main_source
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
