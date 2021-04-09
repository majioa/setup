# vim: noai:ts=3:sts=3:et:sw=3
# Actor spec
module Setup::Actor::Spec
   class << self
      def context_kind
         Setup::Space
      end

      # +apply_to+ generates spec according to the provided setup
      #
      def apply_to space, template = nil
         spec = Setup::Spec.find(space.spec_type)

         rendered = spec.draw(space, template)

         if space.options.output_file
            File.open(space.options.output_file, "w") { |f| f.puts(rendered) }
         end

         rendered
      end
   end
end
