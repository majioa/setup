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
         seq: %w(of_options of_state of_source of_space of_default _name),
         default: "",
      },
      epoch: {
         seq: %w(of_options of_space of_state),
         default: nil,
      },
      version: {
         seq: %w(of_options of_space of_state _version),
         default: nil,
      },
      release: {
         seq: %w(of_options of_space of_state),
         default: "alt1",
      },
      build_arch: {
         seq: %w(of_options of_space of_state),
         default: nil,
      },
      summaries: {
         seq: %w(of_options of_state of_source of_space _summaries),
         default: {}.to_os,
      },
      group: {
         seq: %w(of_options of_state of_space of_source),
         default: "Development/Ruby",
      },
      requires: {
         seq: %w(of_options of_space of_state),
         default: [],
      },
      provides: {
         seq: %w(of_options of_space of_state _provides),
         default: [],
      },
      obsoletes: {
         seq: %w(of_options of_space of_state _obsoletes),
         default: [],
      },
      conflicts: {
         seq: %w(of_options of_space of_state),
         default: [],
      },
      file_list: {
         seq: %w(of_options of_space of_state),
         default: {}.to_os,
      },
      licenses: {
         seq: %w(of_options of_space of_state),
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
         default: ->(this) { OpenStruct.new(
            name: this.changes[0].author,
            email: this.changes[0].email
         ) }
      },
      source_files: {
         seq: %w(of_options of_space of_state _source_files),
         default: { "0": "%name-%version.tar" }.to_os,
      },
      patches: {
         seq: %w(of_options of_space of_state),
         default: {}.to_os,
      },
      build_requires: {
         seq: %w(of_options of_state),
         default: {}.to_os,
      },
      build_pre_requires: {
         seq: %w(of_options of_space of_state _build_pre_requires),
         default: [ "rpm-build-ruby" ],
      },
      changes: {
         seq: %w(of_options of_space of_state _changes),
         default: [],
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
         default: {}.to_os,
      },
      context: {
         seq: %w(of_options of_space of_state),
         default: {},
      },
      comment: {
         seq: %w(of_options of_space of_state),
         default: nil,
      },
      spec_template: {
         seq: %w(of_options of_state),
         default: ->(_) { IO.read(File.join(File.dirname(__FILE__), "rpm.erb"))
         },
      },
      compilables: {
         seq: %w(of_options of_space of_state),
         default: [],
      },
      descriptions: {
         seq: %w(of_options of_state of_source of_space _descriptions),
         default: [],
      },
      readme: {
         seq: %w(of_options of_source of_space of_state),
         default: nil,
      },
      executables: {
         seq: %w(of_options of_source of_space of_state),
         default: nil,
      },
      docs: {
         seq: %w(of_options _docs of_state),
         default: nil,
      },
      devel: {
         seq: %w(of_options _devel of_state),
         default: nil,
      },
      devel_sources: {
         seq: %w(of_options _devel_sources of_state),
         default: nil,
      },
      files: {
         seq: %w(of_options of_space of_state),
         default: []
      }
   }

   def draw spec = nil
      b = binding

      #binding.pry
      ERB.new(spec || spec_template, trim_mode: "<>-", eoutvar: "@spec").result(b)
   end

   include Setup::RpmSpecCore

#   def adopted_name
#      super
#   end
#
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
#   def macros name
#      [ self["context"].__macros[name] ].flatten(1).map { |x| "%#{name} #{x}" }.join("\n")
#   end
#
#   def variables
#      vars = self["context"]
#      vars.__macros = nil
#      vars.delete_field("__macros")
#      vars
#   end
#
   def _secondaries value_in
      names = value_in.map { |x| x.name }

      secondaries = space.sources.reject do |source|
         source.name == space.main_source&.name
      end.map do |source|
         sec = Secondary.new(source: source, spec: self, kind: :lib)

         secondary_parts_for(sec, source)
      end.concat(secondary_parts_for(self, source)).flatten.compact

      secondaries.map do |sec|
         if presec = names.delete(sec.name)
            of_state(:secondaries).find do |osec|
               osec.name == presec
            end.resourced_from(sec)
         else
            sec
         end
      end

      secondaries | names.map do |an|
         Secondary.new(spec: self, kind: an.kind, options: { name: an.adopted_name })
      end
   end

#   def version
#      return @_version if @_version
#
#      @_version = space.version || self["version"]
#   end
#
   def is_same_source? source
      source && self.source == source
   end

   protected

   def _build_requires
      binding.pry
      dep_list =
      space.dependencies.reduce([]) do |deps, dep|
         deph = Setup::Deps.to_rpm(dep.requirement)
         deps | deph.map {|a, b| "#{name.prefix}(#{dep.name}) #{a} #{b}" }
      end.map.with_index { |v, i| [ "#{i}", v ] }.to_h

      eval(dep_list)
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
      build_pre_requires = value_in.dup

      if name.prefix != name.preadopted_prefix
         build_pre_requires.unshift(of_default(:build_pre_requires)[0])
      end

      build_pre_requires
   end

   def _provides value_in
      provides = value_in.dup

      if name.prefix != name.preadopted_prefix
         # TODO optionalize defaults
         provides.unshift("#{name.prefix}-#{name.name} = %EVR")
      end

      provides
   end

   def _obsoletes value_in
      obsoletes = value_in.dup

      if name.prefix != name.preadopted_prefix
         # TODO optionalize defaults
         obsoletes.unshift("#{name.prefix}-#{name.name} < %EVR")
      end

      obsoletes
   end

   def _changes value_in
      new_change =
         if version != of_state(:version)
            # TODO move to i18n and settings file
            description = "- ^ #{of_state(:version)} -> #{version}"
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

      changes = of_state(:changes) || of_default(:changes)

      changes | [ new_change ].compact
   end

   def secondary_parts_for object, source
      PARTS.map do |(kind, func)|
         next object.is_a?(Secondary) && object || nil if !func

         if object.send(func)
            Secondary.new(source: source, spec: self, kind: kind)
         end
      end
   end

   def source
      space.main_source
   end

   def initialize space: nil, state: {}.to_os, options: {}
      @space = space
      @state = state
      #parse_options(options)
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
