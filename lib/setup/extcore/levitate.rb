# Levitate based gemspec detection module
# Sample gems are: comp_tree
#
class Levitate
   def spec
      @spec ||= ::Gem::Specification.new
   end

   def rubyforge_info= _
   end

   def username= _
   end

   def developers
      @developers ||= []
   end

   def rdoc_files= list
      spec.extra_rdoc_files.concat(list)
   end

   protected

   DOC_FILTER = /CHANGES|LICENSE|README|\.rb$/i

   def initialize name
      spec.name = name
      spec.files = Dir["**/**/**"]
      spec.extra_rdoc_files = spec.files.select { |f| DOC_FILTER =~ f }

      vline = IO.read('CHANGES.rdoc').split("\n").find { |x| /^== Version / =~ x }
      /== Version (?<version>[^ ]+)/ =~ vline
      spec.version = version || "0.0"

      readme = IO.read('README.rdoc').gsub(/\n/,"\t")
      / Summary(?<summary>[^=]*)==/x =~ readme
      spec.summary = summary.strip.gsub(/\t/, "\n")
      / Description(?<description>[^=]*)==/x =~ readme
      spec.description = description.strip.gsub(/\t/, "\n")

      Dir.chdir('bin') do
         spec.executables = Dir['*']
      end if File.directory?('bin')
      yield(self)
      spec.authors.concat(developers)
   rescue
      $stderr.puts "[#{$!.class}] #{$!.message}"
   end
end
