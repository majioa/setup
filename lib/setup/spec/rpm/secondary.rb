require 'setup/spec/rpm'

class Setup::Spec::Rpm::Secondary
   attr_reader :source, :spec, :kind

   %w(lib exec doc devel app).each { |name| define_method("is_#{name}?") { @kind.to_s == name } }

   FIELDS = {
      name: nil,
      epoch: nil,
      version: nil,
      release: "alt1",
      build_arch: nil,
      summaries: {},
      group: nil,
      requires: {},
      provides: {},
      obsoletes: {},
      conflicts: {},
      file_list: nil,
   }

   FIELDS.each do |name, default|
      define_method(name) { read_attribute(name, default) }
      define_method("_#{name}") { instance_variable_get(:"@#{name}") }
      define_method("has_#{name}?") { !!instance_variable_get(:"@#{name}")}
   end

   include Setup::RpmSpecCore

   def summaries
      return @summaries if @summaries

      if !summaries = self["summaries"]
         summaries =
            if default_summary = source.summary rescue nil
               OpenStruct.new("" => default_summary)
            else
               {}.to_os
            end
      end

      @summaries = summaries
   end

   def full_name
      return @full_name if @full_name

      prefix = source.respond_to?(:name_prefix) && source.name_prefix || nil
      pre_name = [ prefix, source.name ].compact.join("-")
      @full_name = !pre_name.blank? && pre_name || spec["adopted_name"]
   end

   def options= value
      parse_options(value)
   end

   def resourced_from secondary
      @kind = secondary.kind
      @spec = secondary.spec
      @source = secondary.source

      self
   end

   protected

   def read_attribute name, default = nil
      self[name.to_s] ||
         source.respond_to?(name) && source.send(name) ||
         default.is_a?(Proc) && default[self] ||
         default
   end

   def initialize spec: raise, source: nil, kind: nil, options: {}
      @source = source
      @spec = spec
      @kind = kind
      parse_options(options)
   end
end
