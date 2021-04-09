require 'setup/source/base'

class Setup::Source::Fake < Setup::Source::Base
   def valid?
      true
   end
end
