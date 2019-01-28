require 'bundler'
require 'fileutils'
require 'hoe' rescue nil

module Setup

  # Gem service for Setup.rb.

  class Gem
    # class TooManyGemspecsError < StandardError; end

    DEFAULT_GROUP_NAME = :development

    #
    attr :path

    #
    def initialize(path = Dir.pwd, options={})
      @path = path
    end

    def fullname
       [ name, version ].compact.join('-')
    end

    def name
       spec && spec.name
    end

    def version
       spec && spec.version.to_s.split(".")[0...3].join('.')
    end

    def spec
      @spec ||=
      if defined? Hoe
        if !defined?(HOE)
          load File.join(path, 'Rakefile')
        end

        HOE.spec
      else
        ::Gem::Specification.load(specfile) || ::Gem::Specification.new
      end
    end

    def specfile
      @specfile ||= (
        gemspecs = Dir.foreach('.').select { |f| /\.gemspec$/ =~ f && File.file?(f) }
        # TODO match many as error
        gemspecs.last)
    end

    def store_spec
       FileUtils.mkdir_p('.gemspecs')
       File.open(File.join('.gemspecs', "#{fullname}.gemspec"), "w") { |f| f.puts spec.to_ruby }
    end

    def dsl
      @dsl ||= (
        dsl = Bundler::Dsl.new
        dsl.eval_gemfile(File.join(path, 'Gemfile'))
        dsl)
    rescue Bundler::GemNotFound, Bundler::VersionConflict, ::Gem::InvalidSpecificationException => e
      $stderr.puts "#{e}: #{e.message}"
    end

    def definition
       dsl.to_definition(File.join(path, 'Gemfile.lock'), true)
    end

    def deps_for *groups_in
      groups = [ *groups_in ].flatten.map { |g| g.to_sym == DEFAULT_GROUP_NAME && [ g, :default ] || g }.flatten

      definition.dependencies.select do |dep|
#         binding.pry if dep.name == 'setup'
        (dep.groups & groups).any? && dep.should_include? && !dep.autorequire&.all?
      end
    end

    def deps
      if dsl.gemspecs.first
        dsl.gemspecs.first.dependencies.select { |dep| dep.type == :runtime }
      else
        deps_for(definition.groups - %i(development test))
      end
    end

    def distclean
      FileUtils.rm_rf('.gemspecs')
    end

  end

end
