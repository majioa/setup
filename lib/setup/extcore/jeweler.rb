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

      def spec
         Gem::Specification.new do |g|
            %w(name version license summary description email authors homepage files test_files extra_rdoc_files rdoc_options).each do |name|
               g.send("#{name}=", data[name]) if data[name]
            end
            g.files ||= Dir["**/*"] - excludes
         end
      end

      protected

      def initialize
         @data = OpenStruct.new

         yield(self)
      end

      def method_missing name_in, *args
         if /(?<name>\w+)=/ =~ name_in
            @data[name] = args.first
         else
            raise
         end
      end
   end

   class RubygemsDotOrgTasks
   end

   class GemcutterTasks
   end
end
