# jeweler tasks based gemspec detection module
# example: "polyglot" gem
#
class Jeweler
   class Tasks
      class Files
         attr_reader :data

         def exclude *lists
            @data.exclude = lists
         end

         def initialize
            @data = OpenStruct.new
         end
      end

      attr_reader :data

      def files
         @files ||= Files.new
      end

      def excludes
         @files.data.exclude.map {|e| Dir[e] }.flatten
      end

      def version
         IO.read("VERSION")
      end

      def spec
         @@spec
      end

      protected

      def initialize
         @data ||= OpenStruct.new

         yield(self)

         @@spec =
            Gem::Specification.new do |g|
               @data.each_pair do |name, value|
                  if g.respond_to?("#{name}=")
                     g.send("#{name}=", value)
                  elsif g.respond_to?("#{name}")
                     g.send("#{name}", value)
                  end
               end
               g.files ||= Dir["**/*"] - excludes
               g.version ||= version
            end
      rescue => e
         $stderr.puts("[#{e.class}]: #{e.message}\n\t#{e.backtrace.join("\n\t")}")
      end

      def method_missing name_in, *args
         if /(?<name>\w+)=/ =~ name_in
            @data[name] = args.first
         else
            super
         end
      end
   end

   class RubygemsDotOrgTasks
   end

   class GemcutterTasks
   end
end
