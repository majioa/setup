# POM xml based valid gemspec environment generation module
# example: "ovirt-engine-sdk" gem
# requires "xmllint" to work
#
module Setup::Loader::Pom
   def pom propfile
      dir = File.dirname(propfile)

      specfile = Dir.glob(File.join(dir, '*.gemspec')).first

      re = /require.*?(?<version_file>[^"']+version[^"']*)/
      version_line = Dir.glob(File.join(dir, '**', '*.rb')).map { |x| IO.read(x).split("\n").grep(re).first }.compact.first
      return nil if !version_line or !specfile
      version_file = re.match(version_line)[:version_file]
      re_V = /(?<klass>[^\"\'\(\s]+)::VERSION/
      match = re_V.match(IO.read(specfile).split("\n").grep(re_V).first.to_s)
      if match
         match[:klass]
         version = `xmllint pom.xml --xpath "/*[name()='project']/*[name()='version']/text()"`.strip
         if version != ""
            modtext = "module #{klass};VERSION = '#{version}';end"
            File.open(File.join(dir, "lib", version_file), "w+") {|f| f.puts(modtext) }
         end
      end
   rescue Errno::ENOENT
   end
end
