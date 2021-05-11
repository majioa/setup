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
      if other.is_a?(self.class)
         self.match_by?("kind", other) && self.match_by?("name", other)
      elsif other.is_a?(String)
         ([ autoname ] | aliases).include?(name)
      else
         other.to_s == self.fullname
      end
   end

   def == other
      match?(other)
   end

   def === other
      match?(other)
   end

   def to_s
      fullname
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

   # +fullname+ returns newly reconstructed adopted full name based on the storen data.
   # All the "." and "_" is replaced with "-", and "ruby" prefix with "gem".
   #
   # name.fullname #=> "gem-foo-bar-baz-doc"
   #
   def fullname
      [ autoprefix, autoname, autosuffix ].compact.join("-")
   end

   def original_fullname
      [ prefix, name, suffix ].compact.join("-")
   end

   def autoname
      name&.gsub(/[\._]/, "-")
   end

   def autosuffix
      %w(doc devel).include?(kind) && kind || nil
   end

   def autoprefix
      case kind
      when "lib"
         default_prefix
      when "exec", "app"
         nil
      else
         prefix && default_prefix || prefix
      end
   end

   protected

   def initialize options = {}
      @aliases = options[:name]&.gsub(/[\.\_]+/, "-").split(",")
      @prefix = options[:prefix]
      @suffix = options[:suffix]
      @name = options[:name]
      @support_name = options[:support_name]
      @kind = options[:kind] && options[:kind].to_s ||
         @suffix ||
         @prefix && "lib" ||
         @support_name && "exec" || "app"
   end

   class << self
      def parse name_in, options_in = {}
         m =
            if name_in.is_a?(self)
               name_in.original_fullname.match(RULE)
            else
               name_in.match(RULE)
            end

         raise(InvalidAdoptedNameError) if !m

         options = {
             prefix: m["prefix"],
             suffix: m["suffix"],
             name: m["name"],
         }.merge(options_in)

         new(options)
      end
   end
end
