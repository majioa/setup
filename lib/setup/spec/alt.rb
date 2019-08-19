require 'erb'
require 'setup/spec'
require 'setup/concern/spec'

# Spec generation service for setup.rb
class Setup::Spec::Alt
   include Setup::Concern::Spec

   attr_reader :project

   def pkgname
      gemname&.gsub(/[_\.]+/, '-')
   end

   def gemname
      gem&.name
   end

   def version
      super || gem&.version
   end

   def summary
      super || gem&.summary
   end

   def license
      super || gem&.license
   end

   def subpackages
      @subpackages = project.sources.select do |x|
         x != source && x.is_a?(Setup::Source::Gem)
      end.map { |x| Setup::Spec::Package.new(source: x) }
   end

   def spec
      @spec ||= @template.result(binding)
   end

   def sources
      project.sources
   end

   protected

   def source
      @source ||= sources.sort do |x, y|
         x.is_a?(Setup::Source::Gemfile) && 1 ||
         y.is_a?(Setup::Source::Gemfile) && -1 ||
         x.is_a?(Setup::Source::Rakefile) && 1 ||
         y.is_a?(Setup::Source::Rakefile) && -1 ||
         x.name.size <=> y.name.size
      end.first
   end

   def gem
      @gem ||= sources.sort do |x, y|
         x.is_a?(Setup::Source::Gem) && 1 ||
         y.is_a?(Setup::Source::Gem) && -1 ||
         x.name.size <=> y.name.size
      end.first
   end

   def initialize options = {}
      @project = options[:project] || raise
      path = File.join(Gem::Specification.find_by_name("setup").gem_dir,
                       options[:template] || "share/templates/alt.spec.erb")
      @template = ERB.new(IO.read(path))
   end
end
