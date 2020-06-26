module Setup::Actor::Touch
   class NoDestinationDirError < StandardError ;end
   class NoSourceDirError < StandardError ;end
   class NoFileError < StandardError ;end

   class << self
      def apply context
         target_dir = context['target_dir'] || raise(NoDestinationDirError)
         file = context['file'] || raise(NoFileError)

         target_file = File.join(context['target_prefix'] || '', target_dir, file)
         FileUtils.mkdir_p(File.dirname(target_file))
         FileUtils.touch(target_file)
         $stdout.puts "  >> #{target_file}"
      end
   end
end
