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
         regexp: /Patch(\i+)?:\s+([^\s]+)/i,
         parse_func: :parse_source
      },
      sources: {
         regexp: /Source(\i+)?:\s+([^\s]+)/i,
         parse_func: :parse_source
      },
      build_pre_requires: {
         regexp: /(?:BuildPreReq|BuildRequires\(pre\)):\s+([^\s]+)/i,
         parse_func: :parse_dep
      },
      build_requires: {
         regexp: /BuildRequires:\s+([^\s]+)/i,
         parse_func: :parse_dep
      },
      obsoletes: {
         regexp: /Obsoletes:\s+([^\s]+)/i,
         parse_func: :parse_dep
      },
      provides: {
         regexp: /Provides:\s+([^\s]+)/i,
         parse_func: :parse_dep
      },
      requires: {
         regexp: /Requires:\s+([^\s]+)/i,
         parse_func: :parse_dep
      },
      descriptions: {
         multiline: true,
         regexp: /%description:\s*([^\s].*)?/i,
      },
      packages: {
         multiline: true,
         regexp: /%package:\s+(.+)/i,
      },
      prep: {
         multiline: true,
         regexp: /%prep/i,
      },
      build: {
         multiline: true,
         regexp: /%build/i,
      },
      install: {
         multiline: true,
         regexp: /%install/i,
      },
      check: {
         multiline: true,
         regexp: /%check/i,
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
                     if matched[:name] == key
                        matched[:flow].concat(line)
                     else
                        # binding.pry
                        store_value(opts, matched[:match], matched[:name], matched[:flow])
                        matched = { name: key.to_s, flow: line, match: match }
                     end
                  else
                     matched = { name: key.to_s, flow: line, match: match }
                  end
               end
            end

            opts
         end

         # binding.pry
         store_value(opts, matched[:match], matched[:name], matched[:flow])
      end

      def store_value opts, match, key, flow
         data = SCHEME[key]
         rule = data.is_a?(Hash) && data[:rule] || data
         parse_func = data.is_a?(Hash) && data[:parse_func] || :parse_default
         # binding.pry
         value = method(parse_func)[match, flow]

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

      def parse_source match, _
         { match[2] => match[1] }
      end

      def parse_file_list match, flow
         { match[1] => flow }
      end

      def parse_changes _, flow
         flow.split("* ").map { |p| p.strip }.compact.map { |p| p.split("\n") }
      end

      def parse_dep match, _
         match[1].split(/\s+/)
      end

      def parse_default match, _
         match[1]
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
   end

   def summary
   end

   def license
   end

   def readme
      "README" #change to detect
   end

   def group
      ""
      #@@settings["group"]
   end

   def uri
   end

   def vcs
   end

   def packager
      ""
      #@@settings["packager"]
   end

   def sources
      []
   end

   def aliases
      []
   end

   def description
   end

   def has_master?
   end

   def has_compilable?
   end

   def has_executable?
   end

   def has_epoch?
   end

   def has_doc?
   end

   def has_devel?
   end

   def has_devel_sources?
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
