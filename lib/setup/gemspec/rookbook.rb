# Rookbook based gemspec detection module
#
module Setup::Gemspec::Rookbook
   RE = /\/Rookbook.props$/

   class << self
      def parse propfile
         if File.file?(propfile)
            dir = File.dirname(propfile)

            props = IO.read(propfile)
                      .split("\n")
                      .map do |line|
                           /^(?<key>[^:]+):\s*(?<value>.*)$/ =~ line
                           [ key, value ]
                        end
                      .to_h

            specfile = Dir.glob(File.join(dir, '**', '*.gemspec')).first

            # fix specfile
            oldspec = IO.read(specfile)
            newspec = oldspec.split("\n").map do |x|
               props.reduce(x) { |x, (key, value)| x.gsub(/\$#{key}[: ]*\$/i, value) }
            end
            if oldspec != newspec
               File.open(specfile, 'w+') {|file| file.puts newspec }
            end

            begin
               FileUtils.chdir(File.dirname(specfile)) do
                  Gem::Specification.load(File.basename(specfile))
               end
            rescue Exception
            end
         end
      end
   end
end
