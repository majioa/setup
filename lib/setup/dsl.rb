require 'bundler'
require 'fileutils'
require 'tempfile'

require 'setup'

# DSL service for Setup.rb.
class Setup::DSL
   # class TooManyGemspecsError < StandardError; end

   DEFAULT_GROUP_NAME = :development

   # attributes
   attr_reader :source, :replace_list, :skip_list, :append_list

   def gemfiles
      return @gemfiles if @gemfiles

      gemfiles = dsl.instance_variable_get(:@gemfiles) || []

      @gemfiles = gemfiles.map {|g| g.is_a?(Pathname) && g || Pathname.new(g) }
   end

   def gemfile
      gemfiles.first
   end

   def original_gemfile
      @original_gemfile ||= Pathname.new(File.join(source.root, 'Gemfile'))
   end

   def dsl
      @dsl ||= (
         begin
            dsl =
               Dir.chdir(source.root) do
                  dsl = Bundler::Dsl.new
                  dsl.eval_gemfile(original_gemfile)
                  dsl
               end
         rescue LoadError,
                Bundler::GemNotFound,
                Bundler::GemfileNotFound,
                Bundler::VersionConflict,
                Bundler::Dsl::DSLError,
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
            edsl.dependencies = deps_but(dsl.dependencies, replace_list, skip_list, append_list)
            edsl
         end)
   end

   def definition
      @definition ||= edsl.to_definition(Tempfile.create.path, {})
   end

   def deps
      deps_but(source.deps(:runtime), replace_list, skip_list, append_list)
   end

   def all_deps
      deps_but(source.deps, replace_list, skip_list, append_list)
   end

   def ruby
      { type: source.required_ruby, version: source.required_ruby_version }
   end

   def rubygems
      { version: source.required_rubygems_version }
   end

   def valid?
      gemfiles.any? {|g| g.eql?(original_gemfile) }
   end

   def to_ruby
      spec = source.spec.dup
      spec.dependencies.replace(deps_but(source.deps, replace_list, skip_list, append_list))
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

   protected

   def deps_but deps, replace_list, skip_list, append_list
      deps.map do |dep|
         next if skip_list.include?(dep.name)

         new_req = replace_list.reduce(nil) do |s, (name, req)|
            s || name == dep.name && req
         end

         new_req && Bundler::Dependency.new(dep.name, Gem::Requirement.new([new_req]), options: { "type" => dep.type }) || dep
      end.compact | append_list
   end

   #
   def initialize source: raise, replace_list: nil, skip_list: nil, append_list: nil
      @source = source
      @replace_list = replace_list || {}
      @skip_list = skip_list || []
      @append_list = append_list || []
   end
end
