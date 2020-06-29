require 'setup/concerns'

module Setup::Concerns::Specification
   class << self
      def included mod_in
         mod_in.define_method(:rubyforge_project=) { |_| }
      end
   end
end
