require 'setup/concerns/olddoc'

module Olddoc
   module Gemspec
      include Setup::Concerns::Olddoc
   end

   class << self
      include Setup::Concerns::Olddoc::ClassMethods

      def configname
         '.olddoc.yml'
      end
   end
end
