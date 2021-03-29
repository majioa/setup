module Setup::Space::Spec
   class << self
      def load_from source_in
         attrs = Setup::Spec.load_from(source_in)

         Setup::Space.new(space: { "spec" => attrs })
      end
   end
end
