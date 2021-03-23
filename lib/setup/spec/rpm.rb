require "erb"

require 'setup/spec'

class Setup::Spec::Rpm
   attr_reader :space, :home, :options, :spec, :comment

   @@spec = IO.read("lib/setup/spec/rpm.erb")

   def draw spec = nil
      b = binding

     #binding.pry
      ERB.new(spec || @@spec, trim_mode: "<>-", eoutvar: "@spec").result(b)
   end

   # action
   class << self
      def draw space, spec = nil
         self.new(space: space).draw(spec)
      end
   end

   def altname
   end

   def name
   end

   def pkgname
      space.name
   end

   def epoch
   end

   def version
   end

   def release
   end

   def summary
   end

   def license
   end

   def readme
      "README" #change to detect
   end

   def group
      ""
      #@@settings["group"]
   end

   def uri
   end

   def vcs
   end

   def packager
      ""
      #@@settings["packager"]
   end

   def sources
      []
   end

   def aliases
      []
   end

   def description
   end

   def has_host?
   end

   def has_compilable?
   end

   def has_executable?
   end

   def has_doc?
   end

   def has_devel?
   end

   def has_devel_sources?
   end

   def deps
      if has_host?
      end
      []
   end

   def secondaries
      []
   end

   def history
      []
   end

   # properties

   protected

   def initialize space: raise, home: ENV['GEM_HOME'] || ::Gem.paths.home, options: {}
      @space = space
      @options = options
      @home = home
   end
end
