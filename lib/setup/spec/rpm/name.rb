require 'setup/spec/rpm'

class Setup::Spec::Rpm::Name
   class InvalidAdoptedNameError < StandardError; end
   class UnsupportedMatchError < StandardError; end

   RULE = /^(?:(?<prefix>gem|ruby)-)?(?<name>.*?)(?:-(?<suffix>doc|devel))?$/

   attr_reader :name, :kind, :suffix
   attr_accessor :support_name

   def aliases
      @aliases ||= []
   end

   def prefix
      @prefix ||= kind == "lib" && default_prefix || nil
   end

   def default_prefix
      "gem"
   end

   def support_name= value
      case @support_name = value
      when NilClass
         @kind = kind == "exec" && "app" || @kind
      else
         @kind = kind == "app" && "exec" || @kind
      end
   end

   def match? other
      match_by?("kind", other) && match_by?("name", other)
   end

   def == other
      match?(other)
   end

   def === other
      match?(other)
   end

   def match_by? value, other
      case value
      when "name"
         ([ self.name, self.aliases ].flatten & [ other.name, other.aliases ].flatten).any?
      when "kind"
         self.kind == other.kind
      else
         raise(UnsupportedMatchError.new)
      end
   end

   # +adopted_name+ returns newly reconstructed adopted name based on the storen data.
   # All the "." and "_" is replaced with "-", and "ruby" prefix with "gem".
   #
   # name.adopted_name #=> "gem-foo-bar-baz-doc"
   #
   def adopted_name
      [ preadopted_prefix, preadopted_name, preadopted_suffix ].compact.join("-")
   end

   def origin_name
      [ prefix, name, suffix ].compact.join("-")
   end

   protected

   def preadopted_name
      name&.gsub(/[\._]/, "-")
   end

   def preadopted_suffix
      %w(doc devel).include?(kind) && kind || nil
   end

   def preadopted_prefix
      %w(lib doc devel).include?(kind) && default_prefix || prefix
   end

   def initialize options = {}, prefix: nil, suffix: nil, name: nil, support_name: nil
      @aliases = name&.gsub(/[\.\_]+/, "-")
      @prefix = prefix
      @suffix = suffix
      @name = name
      @support_name = support_name
      @kind = options[:kind] && options[:kind].to_s || suffix ||
         prefix && "lib" ||
         support_name && support_name.name == name && "exec" ||
         "app"
   end

   class << self
      def parse adopted_name, options = {}
         m = adopted_name.match(RULE)

         raise(InvalidAdoptedNameError) if !m

         new(options,
             prefix: m["prefix"],
             suffix: m["suffix"],
             name: m["name"],
             support_name: options.delete(:support))
      end
   end
end
