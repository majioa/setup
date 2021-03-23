# vim: noai:ts=3:sts=3:et:sw=3
# Actor spec
module Setup::Actor::Spec
   class << self
      # function apply
      # generates spec according to the provided setup
      def apply space, template = nil
         spec = Setup::Spec.find(space.spec_type)

         spec.draw(space, template)
      end
   end
end
