module Setup::Actor::Gen
   class NoDestinationDirError < StandardError ;end
   class NoSourceDirError < StandardError ;end
   class NoFileError < StandardError ;end

   class << self
      def allow c
         return true if !c["if"]
         instance_eval(c["if"]) if c["if"].is_a?(String)
      end

      def apply context
         return unless allow(context)
         target_dir = context['target_dir'] || raise(NoDestinationDirError)
         file = context['file'] || raise(NoFileError)

         target_file = File.join(context['target_prefix'] || '', target_dir, file)
         FileUtils.mkdir_p(File.dirname(target_file))
         x = context['body'] || ''
         File.open(target_file, "w+") { |f| f.puts x }
         $stdout.puts "  >> #{target_file}"
      end
   end
end
