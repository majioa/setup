require 'erb'
require 'setup/spec'
require 'setup/concern/spec'

# Spec generation service for setup.rb
class Setup::Spec::Package
   include Setup::Concern::Spec

   attr_reader :source

   #
   def initialize options = {}
      @source = options[:source] || raise
   end
end
