module Setup::Space::Spec
   class << self
      def load_from source_in
         spec = Setup::Spec.load_from(source_in)

         Setup::Space.new(spec: spec)
      end
   end
end
