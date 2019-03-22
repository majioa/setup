require 'fileutils'
require 'tempfile'

require 'setup'

# DSL service for Setup.rb.
class Setup::DSL
   # class TooManyGemspecsError < StandardError; end

   DEFAULT_GROUP_NAME = :development

   # attributes
   attr_reader :source

   def gemfile
      File.join(source.root, 'Gemfile')
   end

   def dsl
      @dsl ||= (
         begin
            require 'bundler'

            dsl = Bundler::Dsl.new
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
      source.deps(:runtime)
   end

   def all_deps
      source.deps
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

   protected

   #
   def initialize source: raise
      @source = source
   end
end
