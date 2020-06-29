require 'setup/concerns/olddoc'

module Wrongdoc
   module Gemspec
      include Setup::Concerns::Olddoc
   end

   class << self
      include Setup::Concerns::Olddoc::ClassMethods

      def configname
         '.wrongdoc.yml'
      end
   end
end
