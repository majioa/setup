require 'hoe/setup'

module Setup::Gemspec::Hoe
   RE = /\/Rakefile$/

   class << self
      attr_reader :hoe

      def parse rakefile
         if defined? Hoe
            if !hoe && File.exist?(rakefile)
               begin
                  stdout = $stdout
                  $stdout = $stderr
                  load rakefile
               rescue Exception => e
                  $stderr.puts "ERROR[#{e.class}]: #{e.message}"
               ensure
                  $stdout = stdout
               end
            end

            hoe&.spec
         end
      end
   end
end
