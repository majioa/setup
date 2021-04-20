require 'setup/spec/rpm'

class Setup::Spec::Rpm::Secondary
   attr_reader :source, :spec

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
         seq: %w(of_options of_state of_source),
         default: "noarch",
      },
      summaries: {
         seq: %w(of_options of_state of_source of_default _summaries),
         default: ""
      },
      group: {
         seq: %w(of_options of_state),
         default: ->(this) { t("spec.rpm.#{this.kind}.group") },
      },
      requires: {
         seq: %w(of_options of_state of_default _requires),
         default: [],
      },
      provides: {
         seq: %w(of_options of_state of_default _provides),
         default: [],
      },
      obsoletes: {
         seq: %w(of_options of_state of_default _obsoletes),
         default: [],
      },
      conflicts: {
         seq: %w(of_options of_state),
         default: [],
      },
      file_list: {
         seq: %w(of_options of_state of_source),
         default: "",
      },
      compilables: {
         seq: %w(of_options of_state of_source),
         default: [],
      },
      descriptions: {
         seq: %w(of_options of_state of_source of_default _descriptions _format_descriptions),
         default: ""
      },
      readme: {
         seq: %w(of_options of_source _readme of_state),
         default: nil,
      },
      executables: {
         seq: %w(of_options of_source of_space of_state),
         default: [],
      },
      docs: {
         seq: %w(of_options _docs of_state),
         default: nil,
      },
      devel: {
         seq: %w(of_options _devel of_state),
         default: nil,
      },
      devel_requires: {
         seq: %w(of_options _devel_requires of_state),
         default: nil,
      },
      devel_sources: {
         seq: %w(of_options _devel_sources of_state),
         default: [],
      },
      files: {
         seq: %w(of_options _files of_state),
         default: []
      },
      dependencies: {
         seq: %w(of_options of_state of_source),
         default: []
      }
   }

   include Setup::RpmSpecCore

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

   def kind
      @kind ||= source.is_a?(Setup::Source::Gem) && :lib || :app
   end

   protected

   def initialize spec: raise, source: nil, kind: nil, options: {}
      @source = source
      @spec = spec
      @kind = kind
      @options = options
      #parse_options(options)
   end
end
