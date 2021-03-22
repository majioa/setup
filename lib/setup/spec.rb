module Setup::Spec
   class InvalidSpecKindError < StandardError; end

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
         specs[spec_kind] || raise(InvalidSpecKindError)
      end
   end
end
