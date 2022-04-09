require 'bundler'
require 'fileutils'
require 'tempfile'

require 'setup'

# DSL service for Setup.rb.
class Setup::DSL
   # class TooManyGemspecsError < StandardError; end

   DEFAULT_GROUP_NAME = :development

   # attributes
   attr_reader :source_file, :replace_list, :skip_list, :append_list, :spec

   def gemfiles
      return @gemfiles if @gemfiles

      gemfiles = dsl.instance_variable_get(:@gemfiles) || []

      @gemfiles = gemfiles.map {|g| g.is_a?(Pathname) && g || Pathname.new(g) }
   end

   def gemfile
      gemfiles.first
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
                Bundler::GemNotFound,
                Bundler::GemfileNotFound,
                Bundler::VersionConflict,
                Bundler::Dsl::DSLError,
                Errno::ENOENT,
                ::Gem::InvalidSpecificationException => e

            Bundler::SharedHelpers.set_env "BUNDLE_GEMFILE", Tempfile.create('Gemfile').path
            dsl = Bundler::Dsl.new
            dsl.instance_variable_set(:@gemfiles, [Pathname.new(ENV["BUNDLE_GEMFILE"])])
            dsl.to_definition(Tempfile.create('Gemfile.lock').path, {})
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

   def original_deps_for groups_in = nil
      groups = defined_groups_of(groups_in)

      original_deps.select do |dep|
         (dep.groups & groups).any? &&
          dep.should_include? # &&
         # (dep.autorequire || [ true ]).all? { |r| r }
      end
   end

   def original_deps
      @original_deps ||= definition.dependencies
   end

   def runtime_deps
      deps_but(original_deps_for(:runtime))
   end

   def defined_groups_of groups_in = nil
      groups_in && ([ groups_in ].flatten.map do |g|
            g == :runtime && (definition.groups - %i(development test)) || group
         end.flatten) || definition.groups
   end

   def deps
      deps_but(original_deps)
   end

   def deps_for groups_in = nil
      deps_but(original_deps_for(groups_in))
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
      spec.dependencies.replace(deps_but(original_deps))
      spec.to_ruby
   end

   def to_gemfile
      deps.group_by { |d| d.name }.map do |name, deps|
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
      @required_ruby_version ||= Gem::Requirement.new(dsl.instance_variable_get(:@ruby_version)&.engine_versions) || ">= 0"
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
