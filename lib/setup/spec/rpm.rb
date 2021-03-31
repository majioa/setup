require "erb"

require 'setup/spec'

class Setup::Spec::Rpm
   attr_reader :home, :options, :spec, :comment
   attr_accessor :space

   MATCHER = /^Name:\s+([^\s]+)/i

   SCHEME = {
      name: /^Name:\s+([^\s]+)/i,
      version: /Version:\s+([^\s]+)/i,
      epoch: /Epoch:\s+([^\s]+)/i,
      release: /Release:\s+([^\s]+)/i,
      summaries: {
         regexp: /Summary(?:\(([^\s:]+)\))?:\s+([^\s].+)/i,
         parse_func: :parse_summary
      },
      license: /License:\s+([^\s].+)/i,
      group: /Group:\s+([^\s]+)/i,
      uri: /Url:\s+([^\s]+)/i,
      vcs: /Vcs:\s+([^\s]+)/i,
      packager: /Packager:\s+([^\s].+)/i,
      build_arch: /BuildArch:\s+([^\s]+)/i,
      patches: {
         non_contexted: true,
         regexp: /Patch(\d+)?:\s+([^\s]+)/i,
         parse_func: :parse_file
      },
      source_files: {
         non_contexted: true,
         regexp: /Source(\d+)?:\s+([^\s]+)/i,
         parse_func: :parse_file
      },
      build_pre_requires: {
         non_contexted: true,
         regexp: /(?:BuildPreReq|BuildRequires\(pre\)):\s+([\w\s<=>\.]+)/i,
         parse_func: :parse_dep
      },
      build_requires: {
         non_contexted: true,
         regexp: /BuildRequires:\s+([\w\s<=>\.]+)/i,
         parse_func: :parse_dep
      },
      obsoletes: {
         regexp: /Obsoletes:\s+([\w\s<=>\.]+)/i,
         parse_func: :parse_dep
      },
      provides: {
         regexp: /Provides:\s+([\w\s<=>\.]+)/i,
         parse_func: :parse_dep
      },
      requires: {
         regexp: /Requires:\s+([\w\s<=>\.]+)/i,
         parse_func: :parse_dep
      },
      conflicts: {
         regexp: /Conflicts:\s+([\w\s<=>\.]+)/i,
         parse_func: :parse_dep
      },
      descriptions: {
         regexp: /%description\s*([^\s].*)?/i,
         parse_func: :parse_description
      },
      secondaries: {
         non_contexted: true,
         regexp: /%package\s+(.+)/i,
         parse_func: :parse_secondary
      },
      prep: {
         non_contexted: true,
         regexp: /%prep/i,
         parse_func: :parse_plain_section
      },
      build: {
         non_contexted: true,
         regexp: /%build/i,
         parse_func: :parse_plain_section
      },
      install: {
         non_contexted: true,
         regexp: /%install/i,
         parse_func: :parse_plain_section
      },
      check: {
         non_contexted: true,
         regexp: /%check/i,
         parse_func: :parse_plain_section
      },
      file_list: {
         regexp: /%files\s*([^\s].*)?/i,
         parse_func: :parse_file_list
      },
      changes: {
         non_contexted: true,
         regexp: /%changelog/i,
         parse_func: :parse_changes
      },
      context: {
         non_contexted: true,
         regexp: /^%(?:(?:define|global)|([^\s]+))\s+(?:([^\s]+)\s+([^\s].*)|(.*))/i,
         parse_func: :parse_context
      }
   }

   @@spec = IO.read("lib/setup/spec/rpm.erb")

   def draw spec = nil
      b = binding

      # binding.pry
      ERB.new(spec || @@spec, trim_mode: "<>-", eoutvar: "@spec").result(b)
   end

   # action
   class << self
      def draw space, spec_in = nil
         spec = space.spec || self.new(space: space)
         spec.draw(spec_in)
      end

      def source source_in
         if source_in.respond_to?(:readlines)
            source_in.rewind
            source_in.readlines
         else
            source_in.split("\n")
         end
      end

      def match? source_in
         MATCHER =~ source(source_in).join("\n")
      end

      def parse source_in
         context = {}
         matched = {}
         match = nil

         opts = source(source_in).reduce({}) do |opts, line|
            SCHEME.find do |(key, rule)|
               match = rule.is_a?(Regexp) && rule.match(line) ||
                       rule.is_a?(Hash) && rule[:regexp].match(line)

               # binding.pry
               if match
                  if matched[:name]
                     if matched[:name] != key
                        store_value(opts, matched[:match], matched[:name], matched[:flow], context)
                        matched = { name: key.to_s, flow: "", match: match }
                     end
                  else
                     matched = { name: key.to_s, flow: "", match: match }
                  end
               end
            end

            if matched
               matched[:flow].concat(line)
            end

            opts
         end

         # binding.pry
         store_value(opts, matched[:match], matched[:name], matched[:flow], context)

         self.new(options: opts)
      end

      def store_value opts, match, key, flow, context
         data = SCHEME[key.to_sym]
         rule = data.is_a?(Hash) && data[:rule] || data
         parse_func = data.is_a?(Hash) && data[:parse_func] || :parse_default
         non_contexted = data.is_a?(Hash) && data[:non_contexted] 
         value = method(parse_func)[match, flow, opts, context]
         copts = !non_contexted && context[:name] && opts["secondaries"][context[:name]] || opts
         # binding.pry

         copts[key] =
         case copts[key]
         when NilClass
            value
         when Array
            copts[key].concat(value)
         when Hash
            copts[key].deep_merge(value)
         else
            [ copts[key], value ]
         end

         opts
      end

      def parse_file match, *_
         { match[1] || "0" => match[2] }
      end

      def parse_file_list match, flow, opts, context
         context.replace(parse_context_line(match[1], opts))
         flow.split("\n")[1..-1].join("\n")
      end

      def parse_changes _, flow, *_
         rows = flow.split("* ").map { |p| p.strip }.compact.map { |p| p.split("\n") }

         rows[1..-1].map do |row|
            /(?<date>^\w+\s+\w+\s+\w+\s+\w+)\s+(?<author>.*)\s*(?:<(?<email>.*)>)\s+(?<version>[\w\.]+)(?:-(?<release>\w+))?$/ =~ row[0]

            {
               date: date,
               author: author.strip,
               email: email,
               version: version,
               release: release,
               description: row[1..-1].join("\n")
            }
         end.reverse
      end

      def parse_dep match, *_
         match[1].scan(/\w+(?:\s+[<=>]+\s+[\d\.]+)?/)
      end

      def parse_default match, *_
         match[1]
      end

      def parse_plain_section _, flow, *_
         flow.split("\n")[1..-1].join("\n")
      end

      def parse_secondary match, flow, opts, context
         context.replace(parse_context_line(match[1], opts))
         { context[:name] => { "name" => context[:name] }}
      end

      def parse_description match, flow, opts, context
         context.replace(parse_context_line(match[1], opts))
         { context[:cp] => flow.split("\n")[1..-1].join("\n") }
      end

      def parse_summary match, *_
         { match[1] => match[2] }
      end

      def parse_context match, *_
         if match[1]
            { "__macros" => { match[1] => match[4] || "#{match[2]} #{match[3]}" }}
         else
            { match[2] => match[3] }
         end
      end

      def parse_context_line line, opts
         key = nil
         context = line.to_s.split(/\s+/).reduce({}) do |res, arg|
            case arg
            when '-l'
               key = :cp
            when '-n'
               key = :fullname
            else
               case key
               when :cp
                  res[:cp] = arg
               when :fullname
                  res[:name] = arg
               else
                  res[:name] = "#{opts["name"]}-#{arg}"
               end
            end

            res
         end

         if context[:name]
            opts["secondaries"] ||= {}
            opts["secondaries"][context[:name]] ||= {}
         end

         context
      end
   end

   %w(
      name
      name
      epoch
      version
      release
      summaries
      license
      build_arch
      group
      uri
      vcs
      packager
      source_files
      patches
      requires
      build_requires
      build_pre_requires
      provides
      obsoletes
      conflicts
      descriptions
      changes
      prep
      build
      install
      check
      file_list
      secondaries
      context
   ).each do |name|
      define_method(name) { self[name] || space.send(name) }
      define_method("_#{name}") { self.options[name] }
      define_method("has_#{name}?") { !!self.options[name] }
   end

   def macros name
      [ self["context"].__macros[name] ].flatten(1).map { |x| "%#{name} #{x}" }.join("\n")
   end

   def variables
      vars = self["context"]
      vars.__macros = nil
      vars.delete_field("__macros")
      vars
   end

   def summary
      summaries[""]
   end

   def altname
   end

   def has_altname?
      !!altname
   end

   def has_compilable?
   end

   def has_executable?
   end

   def readme
      "README" #change to detect
   end

   def has_doc?
   end

   def has_devel?
   end

   def has_devel_sources?
   end
####   def name
#   end
#
#   def pkgname
#      space.name
#   end
#
#   def epoch
#      space.epoch
#   end
#
#   def version
#      space.version
#   end
#
#   def release
#      space.release
#   end
#
#   def summaries
#      space.summaries
#   end
#
#   def summary
#      summaries[nil]
#   end
#
#   def license
#      space.license
#   end
#
#   def build_arch
#      space.build_arch
#   end
#

#   def group
#      space.group
#   end
#
#   def uri
#      space.uri
#   end
#
#   def vcs
#      space.vcs
#   end
#
#   def packager
#      space.packager
#   end
#
#   def source_files
#      space.source_files
#   end
#
#   def patches
#      space.patches
#   end
#
#   def requires
#      space.requires
#   end
#
#   def build_requires
#      space.build_requires
#   end
#
#   def build_pre_requires
#      space.build_pre_requires
#   end
#
#   def provides
#      space.provides
#   end
#
#   def obsoletes
#      space.obsoletes
#   end
#
#   def conflicts
#      space.conflicts
#   end
#
#   def aliases
#      []
#   end
#
#   def descriptions
#      space.descriptions
#   end
#
#   def changes
#      os(space.changes)
#   end
#
#   def prep
#      space.prep
#   end
#
#   def build
#      space.build
#   end
#
#   def install
#      space.install
#   end
#
#   def check
#      space.check
#   end
#
#   def file_list
#      space.file_list
#   end
#


#   def has_epoch?
#      space.spec && space.epoch
#   end
#

#   def has_build_arch?
#      !!build_arch
#   end
#
#   def deps
#      # if has_master?
#      # end
#      []
#   end
#
#   def secondaries
#      os(space.secondaries.values)
#   end
#
#   def history
#      []
#   end
#
   # properties

   def [] name
      self.options[name] && os(self.options[name])
   end

   protected

   def eval value_in
      if value_in.is_a?(String)
         value_in.gsub(/%[{\w}]+/) do |match|
            /%(?:{(?<m>\w+)}|(?<m>\w+))/ =~ match
            options["context"][m]
         end
      else
         value_in
      end
   end

   def os value_in
      value = eval(value_in)
       #  binding.pry

      JSON.parse value.to_json, object_class: OpenStruct
   end

   def initialize space: nil, home: ENV['GEM_HOME'] || ::Gem.paths.home, options: {}
      @space = space
      @options = options
      @home = home
   end
end
