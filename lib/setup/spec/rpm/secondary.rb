require 'setup/spec/rpm'

class Setup::Spec::Rpm::Secondary
   attr_reader :source, :spec, :kind

   STATE = {
      name: {
         seq: %w(of_options of_source of_state of_default _name),
         default: "",
      },
      epoch: {
         seq: %w(of_options of_state),
         default: nil,
      },
      version: {
         seq: %w(of_options of_source of_state _version),
         default: nil,
      },
      release: {
         seq: %w(of_options of_state),
         default: "alt1",
      },
      build_arch: {
         seq: %w(of_options of_state),
         default: nil,
      },
      summaries: {
         seq: %w(of_options of_state of_source _summaries),
         default: {}.to_os,
      },
      group: {
         seq: %w(of_options of_state),
         default: nil,
      },
      requires: {
         seq: %w(of_options of_state),
         default: [],
      },
      provides: {
         seq: %w(of_options of_state),
         default: [],
      },
      obsoletes: {
         seq: %w(of_options of_state),
         default: [],
      },
      conflicts: {
         seq: %w(of_options of_state),
         default: [],
      },
      file_list: {
         seq: %w(of_options of_state),
         default: {}.to_os,
      },
      descriptions: {
         seq: %w(of_options _descriptions),
         default: nil,
      },
      readme: {
         seq: %w(of_options of_source),
         default: nil,
      },
      devel_sources: {
         seq: %w(of_options _devel_sources of_state),
         default: nil,
      },
      files: {
         seq: %w(of_options of_space of_state),
         default: []
      }
   }

   %w(lib exec doc devel app).each do |name|
      define_method("is_#{name}?") { @kind.to_s == name }
   end

   include Setup::RpmSpecCore


#   def full_name
#      return @full_name if @full_name
#
#      prefix = source.respond_to?(:name_prefix) && source.name_prefix || nil
#      pre_name = [ prefix, source.name ].compact.join("-")
#      @full_name = !pre_name.blank? && pre_name || spec["adopted_name"]
#   end
#
#   def options= value
#      parse_options(value)
#   end
#
   def resourced_from secondary
      @kind = secondary.kind
      @spec = secondary.spec
      @source = secondary.source

      self
   end

   protected
#
#   def read_attribute name, default = nil
#      self[name.to_s] ||
#         source.respond_to?(name) && source.send(name) ||
#         default.is_a?(Proc) && default[self] ||
#         default
#   end
#
   def initialize spec: raise, source: nil, kind: nil, options: {}
      @source = source
      @spec = spec
      @kind = kind
      @options = {}
      #binding.pry
      #parse_options(options)
   end
end
