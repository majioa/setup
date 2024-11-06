require 'bundler'
require 'fileutils'
require 'tempfile'

require 'setup'

# DSL service for Setup.rb.
class Setup::DSL
   # group to kind mapping
   GROUP_MAPPING = {
      default: :development,
      development: :development,
      test: :development,
      debug: :development,
      production: :runtime,
      true => :runtime,
   }

   # attributes
   attr_reader :source_file, :replace_list, :skip_list, :append_list, :spec

   def gemfiles
      return @gemfiles if @gemfiles

      gemfiles = dsl.instance_variable_get(:@gemfiles) || []

      @gemfiles = gemfiles.map {|g| g.is_a?(Pathname) && g || Pathname.new(g) }
   end

   def gemfile
      gemfiles.first || original_gemfile || fake_gemfile_path
   end

   def original_gemfile
      @original_gemfile ||= is_source_gemfile && Pathname.new(source_file) || find_gemfile
   end

   def is_source_gemfile
      source_file =~ /Gemfile$/i
   end

   def find_gemfile
      gemfile = Dir[File.join(File.dirname(source_file), '{Gemfile,gemfile}')].first

      gemfile && Pathname.new(gemfile) || nil
   end

   def fake_gemfile_path
      if !@fake_gemfile && @fake_gemfile ||= Tempfile.create('Gemfile')
         @fake_gemfile_path = @fake_gemfile.path

         Bundler::SharedHelpers.set_env "BUNDLE_GEMFILE", @fake_gemfile_path
         @fake_gemfile.close
      end

      @fake_gemfile_path
   end

   def fake_gemlock_path
      if !@fake_gemlock && @fake_gemlock ||= Tempfile.create('Gemfile.lock')
         @fake_gemlock_path = @fake_gemlock.path

         Bundler::SharedHelpers.set_env "BUNDLE_GEMFILE", @fake_gemlock_path
         @fake_gemlock.close
      end

      @fake_gemlock_path
   end

   def dsl
      @dsl ||= (
         begin
            dsl =
               Dir.chdir(File.dirname(source_file)) do
                  dsl = Bundler::Dsl.new
                  dsl.eval_gemfile(original_gemfile)
                  dsl
               end
         rescue LoadError,
                TypeError,
                Bundler::GemNotFound,
                Bundler::GemfileNotFound,
                Bundler::Dsl::DSLError,
                Errno::ENOENT,
                ::Gem::InvalidSpecificationException => e

            dsl = Bundler::Dsl.new
            dsl.instance_variable_set(:@gemfiles, [Pathname.new(fake_gemfile_path)])
            dsl.to_definition(fake_gemlock_path, {})
            Bundler::SharedHelpers.set_env "BUNDLE_GEMFILE", nil

            dsl
         end)
   end

   def edsl
      @edsl ||= (
         begin
            edsl = dsl.dup
            edsl.dependencies = deps_but(dsl.dependencies)
            edsl
         end)
   end

   def definition
      @definition ||=
         Dir.mktmpdir do
            FileUtils.touch("Gemfile")

            edsl.to_definition("./Gemfile", {})
         end
   end

   def original_deps_for kinds_in = nil
      groups = defined_groups_for(kinds_in)

      original_deps.select do |dep|
         (dep.groups & groups).any? &&
          dep.should_include? # &&
         # (dep.autorequire || [ true ]).all? { |r| r }
      end
   end

   def original_deps
      @original_deps ||= definition.dependencies.map do |dep|
         type = dep.groups.map {|g| GROUP_MAPPING[g]}.compact.uniq.sort.first || dep.type
         dep.instance_variable_set(:@type, type)
         valid = !dep.source.is_a?(Bundler::Source::Path)

         valid && dep || nil
      end.compact
   end

   # +gemspecs+ returns either self spec array for a gem DSL, or DSL's gemspec array for Gemfile
   #
   def gemspecs
      spec ? [spec] : dsl.gemspecs
   end

   def extracted_gemspec_deps
      gemspecs.map { |gs| gs.dependencies }.flatten.uniq
   end

   def extracted_gemspec_runtime_deps
      gemspecs.map do |gs|
         gs.dependencies.select {|dep|dep.runtime?}
      end.flatten.uniq
   end

   def runtime_deps kind = :gemspec
      if kind == :gemspec
         deps_but(extracted_gemspec_runtime_deps)
      else
         deps_but(original_deps_for(:runtime))
      end
   end

   def development_deps kind = :gemspec
      deps_but(original_deps_for(:development))
   end

   def defined_groups_for kinds_in = nil
      no_groups =
         [kinds_in].compact.flatten.map do |k|
            GROUP_MAPPING.map do |(g, k_in)|
               k_in != k && g || nil
            end.compact
         end.flatten

      definition.groups - no_groups
   end

   def deps
      deps_but(original_deps) | gemspec_deps
   end

   def gemspec_deps
      gemspecs.map do |gs|
         Gem::Dependency.new(gs.name, Gem::Requirement.new(["= #{gs.version}"]), :development)
      end
   end

   def deps_for kinds_in = nil
      deps_but(original_deps_for(kinds_in)) | gemspec_deps
   end

   def ruby
      { type: required_ruby, version: required_ruby_version }
   end

   def rubygems
      { version: required_rubygems_version }
   end

   def valid?
      gemfiles.any? {|g| g.eql?(original_gemfile) }
   end

   def to_ruby
      spec = self.spec.dup
      deps_in = deps_but(extracted_gemspec_deps)
      deps = spec.dependencies.map {|x| deps_in.find {|a| a.name == x.name }}.compact
      spec.dependencies.replace(deps)
      spec.to_ruby
   end

   def to_gemfile
      deps_but(original_deps).group_by { |d| d.name }.map do |name, deps|
         reqs = deps.map do |dep|
            reqs = dep.requirement.requirements.map {|r| "'#{r[0]} #{r[1]}'" }.join(", ")
         end.join(", ")

         dep = deps.first
         autoreq = dep.respond_to?(:autorequire) &&
                   dep.autorequire &&
                   "require: #{dep.autorequire.any? &&
                             "[" + dep.autorequire.map { |r| r.inspect }.join(', ') + "]" ||
                             "false"}" || nil
         groups = dep.respond_to?(:groups) && dep.groups || []
         g = groups - [ :default ]
         group_list = g.any? && "group: %i(#{groups.join("\n")})" || nil

         [ "gem '#{name}'", reqs, autoreq, group_list ].compact.join(', ')
      end.join("\n")
   end

   def required_rubygems_version
      ">= 0"
   end

   def required_ruby_version
      (f, s) = (dsl.instance_variable_get(:@ruby_version)&.engine_versions&.first || "0").split(/\s+/)
      cv = [ s ? f : ">=", s || f].join(" ")

      @required_ruby_version ||= Gem::Requirement.new(cv)
   end

   def required_ruby
      @required_ruby ||= dsl.instance_variable_get(:@ruby_version)&.engine || "ruby"
   end

   def merge_in other_dsl
      if original_gemfile.to_s != other_dsl.original_gemfile.to_s
         hodeps = other_dsl.original_deps.map {|dep| [dep.name, dep] }.to_h
         original_deps.map {|dep| [dep.name, dep] }.to_h.deep_merge(hodeps).values.map do |dep|
            if dep.is_a?(Array)
               dep.reduce { |res, dep_in| res.merge(dep_in) }
            else
               dep
            end
         end
      end

      self
   end

   protected

   def deps_but deps
      deps.map do |dep|
         next if skip_list.include?(dep.name)

         new_req = replace_list.reduce(nil) do |s, (name, req)|
            s || name == dep.name && req
         end

         new_req && Bundler::Dependency.new(dep.name, Gem::Requirement.new([new_req]), "type" => dep.type) || dep
      end.compact | append_list
   end

   #
   def initialize source_file, options = {}
      raise unless File.file?(source_file)

      @source_file = source_file
      @spec = options[:spec]
      @replace_list = options[:replace_list] || {}
      @skip_list = options[:skip_list] || []
      @append_list = options[:append_list] || []
   end
end
