begin
  require 'pry'
rescue Exception
end

require 'setup/version'
require 'setup/session'
require 'setup/source'
require 'setup/target'

module Setup
   class << self
      def load_file file
         Setup.load(IO.read(file))
      end

      def load string
         if Gem::Version.new(Psych::VERSION) >= Gem::Version.new("4.0.0")
            YAML.load(string,
               aliases: true,
               permitted_classes: [
                  Setup::Source::Fake,
                  Setup::Source::Rakefile,
                  Setup::Source::Gemfile,
                  Setup::Source::Gem,
                  Gem::Specification,
                  Gem::Version,
                  Gem::Dependency,
                  Gem::Requirement,
                  OpenStruct,
                  Symbol,
                  Time,
                  Date
               ])
         else
            YAML.load(string)
         end
      end
   end

end
