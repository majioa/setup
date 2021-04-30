module Setup::Spec
   class InvalidSpecKindError < StandardError; end
   class UndetectedSpecSourceError < StandardError; end

   AUTOMAP =
      %w(Rpm).reduce({}) do |types, name|
         autoload(:"#{name}", File.dirname(__FILE__) + "/spec/#{name.downcase}")
         types.merge(name.to_sym => "Setup/Spec/#{name}".downcase)
      end

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
         specs[spec_kind.to_s] || raise(InvalidSpecKindError.new(spec_kind: spec_kind))
      end

      def load_from source_in, options = {}
         source =
            case source_in
            when IO, StringIO
               source_in.readlines.join("")
            when String
               source_in
            else
               source_in.to_s
            end

         spec = specs.values.find { |spec| spec.match?(source) }

         if spec
            spec.parse(source, options)
         else
            raise(UndetectedSpecSourceError.new(source: source))
         end
      end
   end
end
