require "erb"

require 'setup/spec'

class Setup::Spec::Rpm
   attr_reader :space, :home, :options, :spec, :comment

   MATCHER = /^Name:\s+\w/i

   SCHEME = {
      name: /Name:\s+([^\s]+)/i,
      version: /Version:\s+([^\s]+)/i,
      epoch: /Epoch:\s+([^\s]+)/i,
      release: /Release:\s+([^\s]+)/i,
      summary: /Summary:\s+([^\s].+)/i,
      license: /License:\s+([^\s].+)/i,
      group: /Group:\s+([^\s]+)/i,
      url: /Url:\s+([^\s]+)/i,
      vcs: /Vcs:\s+([^\s]+)/i,
      packager: /Packager:\s+([^\s].+)/i,
      build_arch: /BuildArch:\s+([^\s]+)/i,
      patches: {
         regexp: /Patch(\d+)?:\s+([^\s]+)/i,
         parse_func: :parse_file
      },
      source_files: {
         regexp: /Source(\d+)?:\s+([^\s]+)/i,
         parse_func: :parse_file
      },
      build_pre_requires: {
         regexp: /(?:BuildPreReq|BuildRequires\(pre\)):\s+([\w\s<=>\.]+)/i,
         parse_func: :parse_dep
      },
      build_requires: {
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
         multiline: true,
         regexp: /%description\s*([^\s].*)?/i,
         parse_func: :parse_section
      },
      packages: {
         multiline: true,
         regexp: /%package\s+(.+)/i,
         parse_func: :parse_section
      },
      prep: {
         multiline: true,
         regexp: /%prep/i,
         parse_func: :parse_section
      },
      build: {
         multiline: true,
         regexp: /%build/i,
         parse_func: :parse_section
      },
      install: {
         multiline: true,
         regexp: /%install/i,
         parse_func: :parse_section
      },
      check: {
         multiline: true,
         regexp: /%check/i,
         parse_func: :parse_section
      },
      file_lists: {
         multiline: true,
         regexp: /%files\s*([^\s].*)?/i,
         parse_func: :parse_file_list
      },
      changes: {
         multiline: true,
         regexp: /%changelog/i,
         parse_func: :parse_changes
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
      def draw space, spec = nil
         self.new(space: space).draw(spec)
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
         matched = {}
         match = nil

         opts = source(source_in).reduce({}) do |opts, line|
            SCHEME.find do |(key, rule)|
               match = rule.is_a?(Regexp) && rule.match(line) || rule.is_a?(Hash) && rule[:regexp].match(line)

               # binding.pry
               if match
                  if matched[:name]
                     if matched[:name] != key
                        store_value(opts, matched[:match], matched[:name], matched[:flow])
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
         store_value(opts, matched[:match], matched[:name], matched[:flow])
      end

      def store_value opts, match, key, flow
         data = SCHEME[key.to_sym]
         rule = data.is_a?(Hash) && data[:rule] || data
         parse_func = data.is_a?(Hash) && data[:parse_func] || :parse_default
         value = method(parse_func)[match, flow]
         # binding.pry

         opts[key] =
         case opts[key]
         when NilClass
            value
         when Array
            opts[key].concat(value)
         when Hash
            opts[key].merge(value)
         else
            [ opts[key], value ]
         end

         opts
      end

      def parse_file match, _
         { match[1] || "0" => match[2] }
      end

      def parse_file_list match, flow
         { match[1] => flow }
      end

      def parse_changes _, flow
         flow.split("* ").map { |p| p.strip }.compact.map { |p| p.split("\n") }
      end

      def parse_dep match, _
         match[1].scan(/\w+(?:\s+[<=>]+\s+[\d\.]+)?/)
      end

      def parse_default match, _
         match[1]
      end

      def parse_section match, flow
         # binding.pry
         { match[1] => flow.split("\n")[1..-1].join("\n") }
      end
   end

   def altname
   end

   def name
   end

   def pkgname
      space.name
   end

   def epoch
      space.epoch
   end

   def version
      space.version
   end

   def release
      space.release
   end

   def summary
      space.summary
   end

   def license
      space.license
   end

   def build_arch
      space.build_arch
   end

   def readme
      "README" #change to detect
   end

   def group
      space.group
   end

   def uri
      space.uri
   end

   def vcs
      space.vcs
   end

   def packager
      space.packager
   end

   def source_files
      space.source_files
   end

   def patches
      space.patches
   end

   def requires
      space.requires
   end

   def build_requires
      space.build_requires
   end

   def build_pre_requires
      space.build_pre_requires
   end

   def provides
      space.provides
   end

   def obsoletes
      space.obsoletes
   end

   def conflicts
      space.conflicts
   end

   def aliases
      []
   end

   def descriptions
      space.descriptions
   end

   def has_master?
      # has altname
   end

   def has_compilable?
   end

   def has_executable?
   end

   def has_epoch?
      space.spec && space.epoch
   end

   def has_doc?
   end

   def has_devel?
   end

   def has_devel_sources?
   end

   def has_build_arch?
      !!build_arch
   end

   def deps
      # if has_master?
      # end
      []
   end

   def secondaries
      []
   end

   def history
      []
   end

   # properties

   protected

   def initialize space: raise, home: ENV['GEM_HOME'] || ::Gem.paths.home, options: {}
      @space = space
      @options = options
      @home = home
   end
end
