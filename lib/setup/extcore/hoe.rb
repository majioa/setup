class Hoe
   DOC_FILTER = /CHANGELOG|LICENSE|README|\.rb$/i
   PLUGINS = %w{rdoc hoe}

   def initialize name
      @spec ||= ::Gem::Specification.new
      @spec.name = name
   end

   def spec
      @spec
   end

   class << self
      def plugin plugin
        @plugins ||= [@plugins].compact.flatten | [plugin.to_s]
      end

      # definitors
      def developer value, email
         @spec.spec.authors << value
         @spec.spec.email = [@spec.spec.email, email].compact.flatten
      end

      def license value
         @spec.spec.licenses |= [value]
      end

      def require_ruby_version data
         @spec.spec.required_ruby_version = data
      end

      def dependency name, dep, group = :runtime
         @spec.spec.dependencies << Gem::Dependency.new(name, Gem::Requirement.new([dep]), group)
      end

      # spec
      def spec name = nil
         main

         return @spec.spec if @spec

         plugin("hoe")

         @spec ||= self.new(name)

         init(name)
         yield if block_given?

         @spec.spec
      end

      def name
         @spec.spec.name
      end

      def main
         @main = TOPLEVEL_BINDING.eval('self')
         @main.extend(Main)
         @main.include(Main)
      end

      # autoload hoe modules folder and assign plugins
      def init name
         @spec.spec.files = IO.read('Manifest.txt').split("\n")
         @spec.spec.extra_rdoc_files = @spec.spec.files.select { |f| DOC_FILTER =~ f }
         vline = IO.read('History.rdoc').split("\n").find { |x| /^===/ =~ x }
         /=== (?<version>[^ ]+)/ =~ vline
         @spec.spec.version = version

         Dir.glob(Dir.pwd + '/lib/hoe/*.rb').each { |x| require_relative(x) }
         self.constants.map {|c| self.const_get(c) }.select {|x| x.is_a?(Module) }.each {|x| extend(x) }
         send("initialize_#{@spec.spec.name}")

         (@plugins & PLUGINS).each do |name|
            dependency(name, ">= 0", :development)
         end
      end
   end

   module Main
      def method_missing method_name, *args
         Hoe.send(method_name, *args)
      end
   end
end
