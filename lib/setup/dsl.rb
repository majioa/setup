require 'fileutils'
require 'tempfile'

require 'setup'

# DSL service for Setup.rb.
class Setup::DSL
   # class TooManyGemspecsError < StandardError; end

   DEFAULT_GROUP_NAME = :development

   # attributes
   attr_reader :source, :replace_list

   def gemfile
      File.join(source.root, 'Gemfile')
   end

   def dsl
      @dsl ||= (
         begin
            require 'bundler'

            dsl = Dir.chdir(source.root) { Bundler::Dsl.new }
            dsl.eval_gemfile(gemfile)
            dsl
         rescue LoadError,
                Bundler::GemNotFound,
                Bundler::GemfileNotFound,
                Bundler::VersionConflict,
                Bundler::Dsl::DSLError,
                ::Gem::InvalidSpecificationException => e
           nil
         end)
   end

   def deps
      deps_but(source.deps(:runtime), replace_list)
   end

   def all_deps
      deps_but(source.deps, replace_list)
   end

   def ruby
      { type: source.required_ruby, version: source.required_ruby_version }
   end

   def rubygems
      { version: source.required_rubygems_version }
   end

   def valid?
      !dsl.nil?
   end

   def to_ruby
      spec = source.spec.dup
      spec.dependencies.replace(deps_but(source.deps, replace_list))
      spec.to_ruby
   end

   def to_gemfile
      deps = source.deps.replace(deps_but(source.deps, replace_list))
      deps.map do |dep|
         reqs = dep.requirement.requirements.map {|r| "'#{r[0]} #{r[1]}'" }.join(", ")
         "gem '#{dep.name}', #{reqs}"
      end.join("\n")
   end

   protected

   def deps_but deps, replace_list
      deps.map do |dep|
         new_req = replace_list.reduce(nil) do |s, (name, req)|
            s || name == dep.name && req
         end

         new_req && Gem::Dependency.new(dep.name, Gem::Requirement.new([new_req]), dep.type) || dep
      end
   end

   #
   def initialize source: raise, replace_list: {}
      @source = source
      @replace_list = replace_list
   end
end
