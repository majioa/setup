# GIT-VERSION-GEN version generator based gemspec preparser
# example: "kgio" gem
#
module Setup::Loader::GitVersionGen
   def git_version_gen execfile
      IO.popen(execfile) do |io|
         debug(io.readlines)
      end

      dir = File.dirname(execfile)
      version_line = IO.read(File.join(dir, "GIT-VERSION-FILE"))
      if /=(?<version>.*)/ =~ version_line
         ENV["VERSION"] = version.strip
      end

      # dot manifest generation
      files = Dir["*/**/*"].select {|x| File.file?(x) }
      File.open(".manifest", "w+") {|f| f.puts(files.join("\n"))}

      # make documentaion
      if File.directory?('Documentation')
         `make -C Documentation`
      end

      if !File.exist?('.manifest') || !File.exist?('.gem-manifest')
         files = Dir.glob("**/*", File::FNM_DOTMATCH).reject do |f|
            /\/\.git/ =~ f || File.directory?(f)
         end

         File.open(File.join('.gem-manifest'), "w") { |f| f.puts files }
         FileUtils.cp('.gem-manifest', '.manifest')
      end

      nil
   end
end
