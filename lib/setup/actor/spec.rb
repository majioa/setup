# vim: noai:ts=3:sts=3:et:sw=3
# Actor spec
module Setup::Actor::Spec
   class << self
      # function apply
      # generates spec according to the provided setup
      def apply setup
         spec = Setup::Spec.find(setup.spec_type)

         spec.draw(setup)
      end
   end
end
