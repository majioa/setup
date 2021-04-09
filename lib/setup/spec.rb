module Setup::Spec
   class InvalidSpecKindError < StandardError; end
   class UndetectedSpecSourceError < StandardError; end

   autoload(:Rpm, 'setup/spec/rpm')

   AUTOMAP = {
      Rpm: "setup/spec/rpm",
   }

   class << self
      def kinds
         specs.keys
      end

      def specs
         @specs ||= AUTOMAP.keys.map do |const|
            require(AUTOMAP[const])
            [ const.to_s.downcase, const_get(const) ]
         end.to_h
      end

      def find spec_kind
         specs[spec_kind] || raise(InvalidSpecKindError.new(spec_kind: spec_kind))
      end

      def load_from source_in
         spec = specs.values.find { |spec| spec.match?(source_in) }

         if spec
            spec.parse(source_in)
         else
            raise(UndetectedSpecSourceError.new(source_in: source_in))
         end
      end
   end
end
