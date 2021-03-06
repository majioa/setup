class Setup::Spec::Rpm::Name
   class InvalidAdoptedNameError < StandardError; end
   class UnsupportedMatchError < StandardError; end

   RULE = /^(?<full_name>(?:(?<prefix>gem|ruby)-)?(?<name>.*?))(?:-(?<suffix>doc|devel))?$/

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

   def match? other, deep = false
      case other
      when self.class
         self.match_by?(:kind, other) && self.match_by?(:name, other)
      when String, Symbol
         ([ autoname, fullname ] | [ aliases ].flatten).include?(other.to_s)
      else
         other.to_s == self.fullname
      end || deep && self.match_by?(:support_name, other)
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

   def merge other
      options =
         %w(prefix suffix name support_name kind).map do |prop|
            [ prop.to_sym, other.send(prop) || self.send(prop) ]
         end.to_h

      self.class.new(options.merge(aliases: self.aliases | other.aliases))
   end

   def match_by? value, other
      case value
      when :name
         ([ self.name, self.aliases ].flatten & [ other.name, other.aliases ].flatten).any?
      when :kind
         self.kind == other.kind
      when :support_name
         self.support_name === (other.is_a?(self.class) && other.support_name || other)
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
         prefix
      else
         prefix && default_prefix || prefix
      end
   end

   protected

   def initialize options = {}
      @aliases = options.fetch(:aliases, []) | options.fetch(:name, "").gsub(/[\.\_]+/, "-").split(",")
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

         aliases_in = (options_in[:aliases] || []).flatten.uniq
         subaliases = aliases_in - [ m["full_name"] ]
         #aliases = subaliases | [ m["full_name"] ]

         raise(InvalidAdoptedNameError) if !m

         prefixed = subaliases.size >= aliases_in.size
         options = {
            prefix: prefixed && m["prefix"] || nil,
            #prefix: subaliases.blank? && m["prefix"] || nil,
            #prefix: m["prefix"],
            suffix: m["suffix"],
            #name: m["name"],
            name: prefixed && m["name"] || m["full_name"],
            #name: subaliases.blank? && m["name"] || m["full_name"],
         }.merge(options_in).merge({
            aliases: subaliases | [ m["full_name"] ]
         })

         options[:name] = options[:name].blank? && options[:aliases].first || options[:name]
         #binding.pry if name_in =~ /ruby/

         new(options)
      end
   end
end
