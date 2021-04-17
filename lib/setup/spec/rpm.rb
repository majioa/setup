require "erb"

require 'setup/spec'

class Setup::Spec::Rpm
   attr_reader :home, :spec, :comment
   attr_accessor :space

   autoload(:Name, 'setup/spec/rpm/name')
   autoload(:Parser, 'setup/spec/rpm/parser')
   autoload(:Secondary, 'setup/spec/rpm/secondary')

   PARTS = {
      lib: nil,
      exec: :has_executable?,
      doc: :has_docs?,
      devel: :has_devel?,
   }

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
      file_list: nil,
      licenses: [],
      uri: nil,
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

   @@spec = IO.read(File.join(File.dirname(__FILE__), "rpm.erb"))

   def draw spec = nil
      b = binding

      #binding.pry
      ERB.new(spec || @@spec, trim_mode: "<>-", eoutvar: "@spec").result(b)
   end

   FIELDS.each do |name, default|
      define_method(name) { read_attribute(name, default) }
      define_method("_#{name}") { instance_variable_get(:"@#{name}") }
      define_method("has_#{name}?") { !!instance_variable_get(:"@#{name}") }
   end

   include Setup::RpmSpecCore

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

   def source_files
      return @_source_files if @_source_files

      source_files = self["source_files"].dup

      if source_files[:"0"] != "%name-%version.tar"
         # TODO state defaults
         source_files[:"0"] = "%name-%version.tar"
      end

      @_source_files = source_files
   end

   def build_pre_requires
      return @_build_pre_requires if @_build_pre_requires

      build_pre_requires = self["build_pre_requires"].dup

      if autoname.prefix != autoname.preadopted_prefix
         # TODO state defaults
         build_pre_requires[build_pre_requires.to_h.values.count.to_s] = "rpm-build-ruby"
      end

      @_build_pre_requires = build_pre_requires
   end

   def provides
      return @_provides if @_provides

      provides = self["provides"].dup

      if autoname.prefix != autoname.preadopted_prefix
         # TODO state defaults
         provides[provides.to_h.values.count.to_s] = "#{autoname.prefix}-#{autoname.name} = %EVR"
      end

      @_provides = provides
   end

   def obsoletes
      return @_obsoletes if @_obsoletes

      obsoletes = self["obsoletes"].dup

      if autoname.prefix != autoname.preadopted_prefix
         # TODO state defaults
         obsoletes[obsoletes.to_h.values.count.to_s] = "#{autoname.prefix}-#{autoname.name} < %EVR"
      end

      @_obsoletes = obsoletes
   end

   def secondaries
      return @_secondaries if @_secondaries

      autonames = self[:secondaries].to_h.map { |(_, x)| x.autoname }

      secondaries = space.sources.reject do |source|
         source.name == space.main_source&.name
      end.map do |source|
         sec = Secondary.new(source: source, spec: self, kind: :lib)

         secondary_parts_for(sec, source)
      end.concat(secondary_parts_for(self, source)).flatten.compact

      secondaries.map do |sec|
         if presec = autonames.delete(sec.autoname)
            self[:secondaries][presec.origin_name].resourced_from(sec)
         else
            sec
         end
      end

      @_secondaries = secondaries | autonames.map do |an|
         Secondary.new(spec: self, kind: an.kind, options: { adopted_name: an.adopted_name })
      end
   end

   def version
      return @_version if @_version

      @_version = space.version || self["version"]
   end

   def changes
      return @_changes if @_changes

      new_change =
         if version != self["version"]

            # TODO move to i18n and settings file
            description = "- ^ #{self["version"]} -> #{version}"
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

      @_changes = self["changes"] | [ new_change ].compact
   end

   def is_same_source? source
      source && self.source == source
   end

   protected

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

   def read_attribute name, default = nil
      self[name.to_s] ||
         space.respond_to?(name) && space.send(name) ||
         (space.main_source.send(name) rescue nil) ||
         default.is_a?(Proc) && default[self] ||
         default
   end

   def initialize space: nil, home: ENV['GEM_HOME'] || ::Gem.paths.home, options: nil
      @space = space
      @home = home
      parse_options(options)
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
