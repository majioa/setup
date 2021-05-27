require "erb"

require 'setup/spec'

class Setup::Spec::Rpm
   attr_reader :spec, :comment

   %w(Name Parser Secondary).reduce({}) do |types, name|
      autoload(:"#{name}", File.dirname(__FILE__) + "/rpm/#{name.downcase}")
   end

   OPTIONS = %w(source conflicts uri vcs maintainer_name maintainer_email
                source_files patches build_pre_requires context comment
                readme executables ignored_names main_source dependencies
                valid_sources available_gem_list rootdir aliased_names
                time_stamp devel_dep_setup)

   PARTS = {
      lib: nil,
      exec: :has_executables?,
      doc: :has_docs?,
      devel: :has_devel?,
   }

   STATE_CHANGE_NAMES = %w(name version summaries licenses group uri vcs
      packager build_arch source_files build_pre_requires descriptions secondaries
      prep build install check file_list)

   STATE = {
      name: {
         seq: %w(of_options of_state of_source of_default _name),
         default: "",
      },
      pre_name: {
         seq: %w(of_options of_state of_default _pre_name),
         default: "",
      },
      epoch: {
         seq: %w(of_options of_source of_state),
         default: nil,
      },
      version: {
         seq: %w(of_options of_source of_state of_default _version),
         default: ->(this) { this.options.time_stamp },
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
         seq: %w(of_options of_state),
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
         seq: %w(of_options of_state of_source),
         default: nil,
      },
      vcs: {
         seq: %w(of_options of_state of_source _vcs),
         default: nil,
      },
      packager: {
         seq: %w(of_options of_state),
         default: ->(this) do
            OpenStruct.new(
               name: this.options.maintainer_name || "Spec Author",
               email: this.options.maintainer_email || "author@example.org"
            )
         end
      },
      source_files: {
         seq: %w(of_options of_state of_default _source_files),
         default: { "0": "%name-%version.tar" }.to_os,
      },
      patches: {
         seq: %w(of_options of_state),
         default: {}.to_os,
      },
      build_requires: {
         seq: %w(of_options of_state of_default _build_requires),
         default: [],
      },
      build_pre_requires: {
         seq: %w(of_options of_state of_default _build_pre_requires),
         default: [ "rpm-build-ruby" ],
      },
      changes: {
         seq: %w(of_options of_state of_source of_default _changes),
         default: ->(this) do
            version = this.version
            description = t("spec.rpm.change.new", binding: binding)
            release = this.of_options(:release) || this.of_state(:release) || "alt1"

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
         seq: %w(of_options of_state),
         default: "%setup",
      },
      build: {
         seq: %w(of_options of_state),
         default: "%ruby_build",
      },
      install: {
         seq: %w(of_options of_state),
         default: "%ruby_install",
      },
      check: {
         seq: %w(of_options of_state),
         default: "%ruby_test",
      },
      secondaries: {
         seq: %w(of_options of_state of_default _secondaries),
         default: [],
      },
      context: {
         seq: %w(of_options of_state),
         default: {},
      },
      comment: {
         seq: %w(of_options of_state),
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
         seq: %w(of_options of_source _readme of_state),
         default: nil,
      },
      executables: {
         seq: %w(of_options of_source of_state),
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
         seq: %w(of_options of_state),
         default: []
      },
      aliased_names: {
         seq: %w(of_options of_state),
         default: []
      },
      available_gem_list: {
         seq: %w(of_options of_state _available_gem_list),
         default: {}
      },
      versioned_gem_list: {
         seq: %w(of_options of_state _versioned_gem_list),
         default: {}
      },
      rootdir: {
         seq: %w(of_options of_state),
         default: nil
      },
      rake_build_tasks: {
         seq: %w(of_options of_source of_state of_default _rake_build_tasks),
         default: ""
      }
   }

   include Setup::RpmSpecCore

   def render spec = nil
      b = binding

      #binding.pry
      ERB.new(spec || spec_template, trim_mode: "<>-", eoutvar: "@spec").result(b).strip
   end

   def macros name
      [ context.__macros[name] ].flatten(1).map { |x| "%#{name} #{x}" }.join("\n")
   end

   def is_same_source? source_in
      source_in && source == source_in
   end

   def kind
      @kind ||= source.is_a?(Setup::Source::Gem) && :lib || :app
   end

   def state_kind
      @state_kind ||= options.main_source.is_a?(Setup::Source::Gem) && :lib || :app
   end

   def state_sources
      packages = [ self ] | (of_state(:secondaries) || of_default(:secondaries))

      packages.map do |package|
         package.options&.main_source ||
            #case package.of_state(:name)&.kind || package.state_kind.to_s
            case package.pre_name&.kind || package.state_kind.to_s
            when "lib"
               spec = Gem::Specification.new do |s|
                  s.name = package.name.autoname
                  s.version = package.state["version"] || package.source.version
                  s.summary = package.state["summaries"]&.[]("") || package.source.summary
               end

               Setup::Source::Gem.new({"spec" => spec})
            when "app"
               #name = package.of_options(:name) ||
               #   package.of_state(:name) ||
               #   rootdir && rootdir.split("/").last
               name = package.pre_name
               #binding.pry

               Setup::Source::Gemfile.new({
                  "name" => name.to_s,
                  "version" => of_options(:version) || of_state(:version)
               })
            end
      end.compact
   end

   protected

   def ruby_build
      @ruby_build ||= variables.ruby_build&.split(/\s+/) || []
   end

   def _versioned_gem_list value_in
      value_in.to_os.merge(available_gem_list.merge(gem_versionings))
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
      end.map do |aliases|
         aliases |
            [ aliased_names, [ autoaliases ]].map do |a|
               a.reject { |x| (x & aliases).blank? }
            end.flatten
      end
   end

   def autoaliases
      @autoaliases =
         [ secondaries.map do |sec|
            sec.name.name
         end, secondaries.map do |sec|
            sec.name.support_name&.name
         end ].transpose.select do |x|
            x.compact.uniq.size > 1
         end.flatten
   end

   def _ruby_alias_names_local value_in
      return @ruby_alias_names_local if @ruby_alias_names_local

      names = [ source&.name, name&.name ].compact.uniq

      @ruby_alias_names_local = value_in | (names.size > 1 && [ names ] || [])
   end

   def _secondaries value_in
      names = value_in.map { |x| x.name }

      #binding.pry
      secondaries = sources.reject do |source_in|
         source_in.name == source&.name ||
            ignored_names.include?(source_in.name)
      end.map do |source|
         sec = Secondary.new(source: source,
                             spec: self,
                             state: { context: context },
                             options: { name_prefix: name.prefix,
                                        available_gem_list: available_gem_list })

         secondary_parts_for(sec, source)
      end.concat(secondary_parts_for(self, source)).flatten.compact

      #binding.pry
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

      #binding.pry
      secondaries =
         secondaries | names.map do |an|
            sec = value_in.find { |sec| sec.name == an }

            if sec.is_a?(Secondary)
               sec
            elsif sec.is_a?(OpenStruct)
               source = sources.find { |s| sec.name == s.name }
               #name = Setup::Spec::Rpm::Name.parse(an.fullname)

               Secondary.new(spec: self,
                             kind: sec.name.kind,#an.kind
                             state: sec,
                             source: source,
                             options: { name: sec.name,
                                        available_gem_list: available_gem_list })
            end
         end

      secondaries.select do |sec|
         sec.kind != :devel || options.devel_dep_setup != :skip
      end
   end

   def _build_requires value_in
      deps_pre = value_in.map do |dep|
         if !m = dep.match(/gem\((.*)\) ([>=<]+) ([\w\d\.\-]+)/)
            dep
            #Gem::Dependency.new(m[1], Gem::Requirement.new(["#{m[2]} #{m[3]}"]), :runtime)
         end
      end.compact | dependencies

      #TODO move fo filter options
      deps_pre -= ["ruby-tool-setup"]
      filtered = replace_versioning(deps_pre).reject do |dep|
         dep.is_a?(Gem::Dependency) && dep.type == :development && options.devel_dep_setup == :skip
      end

      append_versioning(filtered).reduce([]) do |deps, dep|
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
      list = sources.map do |source|
            source.licenses
         end.flatten.uniq

      list.blank? && value_in || list
   end

   def state_changed?
      @state_changed = STATE_CHANGE_NAMES.any? do |property|
         if property == "secondary"
            [ of_state(property), self.send(property) ].transpose.any? do |(first, second)|
               first.name != second.name
            end
         else
            of_state(property) != self.send(property)
         end
#
#         when String, Name, Gem::Version, NilClass,
#         binding.prya
#         when Array
#         binding.pry
#            of_state(property) == self.send(property)
#         when OpenStruct
#         binding.pry
#            of_state(property) == self.send(property)
#         else
#         binding.pry
#         end
#
#         true
      end
   end

   def _changes value_in
      new_change =
         if of_state(:version)
            if self.version != of_state(:version)
               # TODO move to i18n and settings file
               previous_version = of_state(:version)
               version = self.version
               description = t("spec.rpm.change.upgrade", binding: binding)
               release = "alt1"
            elsif state_changed?
               version = self.version
               description = t("spec.rpm.change.fix", binding: binding)
               release_version_bump =
               # TODO suffix
               /alt(?<release_version>.*)/ =~ of_state(:release)
               release_version_bump =
                  if release_version && release_version.split(".").size > 1
                     Gem::Version.new(release_version).bump.to_s
                  elsif release_version
                     release_version + '.1'
                  else
                     "1"
                  end
               release = "alt" + release_version_bump
            end

            packager_name = options.maintainer_name || packager.name
            packager_email = options.maintainer_email || packager.email
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

   def _rake_build_tasks value_in
      /--pre=(?<list>[^\s]*)/ =~ %w(context __macros ruby_build).reduce(state) {|r, a| r&.[](a) }

      value_in.split(",") | (of_state(:ruby_on_build_rake_tasks) || list || "").split(",")
   end

   def secondary_parts_for object, source
      PARTS.map do |(kind, func)|
         next object.is_a?(Secondary) && object || nil if !func

         if object.send(func)
            Secondary.new(source: source,
                          spec: self,
                          kind: kind,
                          host: object,
                          state: { context: context },
                          options: { name_prefix: kind != :exec && name.prefix || nil,
                                     available_gem_list: available_gem_list })
         end
      end
   end

   def source
      @source ||= options.main_source || sources.find {|source_in| pre_name == source_in.name }
   end

   def sources
      @sources ||=
         state_sources.reduce(options.valid_sources || []) do |res, source_in|
            res.find { |x| Name.parse(x.name) == Name.parse(source_in.name) } && res || res | [ source_in ]
         end
   end

   def initialize state: {}, options: {}
      @state = state
      @options = options.to_os
   end

   class << self
      def match? source_in
         Parser.match?(source_in)
      end

      def parse source_in, options = {}.to_os
         state = Parser.new.parse(source_in, options)

         Setup::Spec::Rpm.new(state: state, options: options)
      end

      def render space, spec_in = nil
         spec = space.spec || self.new(options: space.options_for(self))
         spec.render(spec_in)
      end
   end
end
