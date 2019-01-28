require 'hoe/setup'

module Setup::Gemspec::Hoe
   RE = /\/Rakefile$/

   class << self
      attr_reader :hoe

      def parse rakefile
         if defined? Hoe
            if !hoe && File.exist?(rakefile)
               begin
                  load rakefile
               rescue Exception => e
                  $stderr.puts "ERROR[#{e.class}]: #{e.message}"
               end
            end

            hoe&.spec
         end
      end
   end
end
