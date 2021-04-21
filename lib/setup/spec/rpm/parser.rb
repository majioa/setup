require 'setup/spec/rpm'

class Setup::Spec::Rpm::Parser
   MATCHER = /^Name:\s+([^\s]+)/i

   SCHEME = {
      name: {
         non_contexted: true,
         regexp: /^Name:\s+([^\s]+)/i,
         parse_func: :parse_name
      },
      version: {
         non_contexted: true,
         regexp: /Version:\s+([^\s]+)/i,
         parse_func: :parse_version
      },
      epoch: /Epoch:\s+([^\s]+)/i,
      release: /Release:\s+([^\s]+)/i,
      summaries: {
         regexp: /Summary(?:\(([^\s:]+)\))?:\s+([^\s].+)/i,
         parse_func: :parse_summary
      },
      licenses: {
         non_contexted: true,
         regexp: /License:\s+([^\s].+)/i,
         parse_func: :parse_license
      },
      group: /Group:\s+([^\s]+)/i,
      uri: /Url:\s+([^\s]+)/i,
      vcs: /Vcs:\s+([^\s]+)/i,
      packager: {
         non_contexted: true,
         regexp: /Packager:\s+(?<name>.*)\s*(?:<(?<email>.*)>)$/i,
         parse_func: :parse_packager
      },
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

   def source source_in
      if source_in.respond_to?(:readlines)
         source_in.rewind
         source_in.readlines
      else
         source_in.split("\n")
      end
   end

   def parse source_in
      context = {}
      matched = {}
      match = nil

      state = source(source_in).reduce({}) do |state, line|
         SCHEME.find do |(key, rule)|
            match = rule.is_a?(Regexp) && rule.match(line) ||
                    rule.is_a?(Hash) && rule[:regexp].match(line)

            # binding.pry
            if match
               if matched[:name]
                  if matched[:name] != key
                     store_value(state, matched[:match], matched[:name], matched[:flow], context)
                     matched = { name: key.to_s, flow: "", match: match }
                  end
               else
                  matched = { name: key.to_s, flow: "", match: match }
               end

            end
         end

         if matched
            matched[:flow] << line + "\n"
         end

         state
      end

      # binding.pry
      store_value(state, matched[:match], matched[:name], matched[:flow], context)

      Setup::Spec::Rpm.new(state: state)
   end

   def store_value opts, match, key, flow, context
      data = SCHEME[key.to_sym]
      rule = data.is_a?(Hash) && data[:rule] || data
      parse_func = data.is_a?(Hash) && data[:parse_func] || :parse_default
      non_contexted = data.is_a?(Hash) && data[:non_contexted]
      value = method(parse_func)[match, flow, opts, context]
      copts = !non_contexted && context[:name] && opts["secondaries"].find do |sec|
         sec.name == Setup::Spec::Rpm::Name.parse(context[:name])
      end || opts
      #binding.pry

      copts[key] =
      case copts[key]
      when NilClass
         value
      when Array
      #binding.pry
         copts[key] | [ value.is_a?(Hash) && value.to_os || value ].flatten
      when Hash, OpenStruct
      #binding.pry
         copts[key].deep_merge(value)
      else
      #binding.pry
         [ copts[key], value ]
      end

      opts
   end

   def parse_name match, *_
      Setup::Spec::Rpm::Name.parse(match[1])
   end

   def parse_file match, *_
      { match[1] || "0" => match[2] }.to_os
   end

   def parse_file_list match, flow, opts, context
      context.replace(parse_context_line(match[1], opts))
      flow.split("\n")[1..-1].join("\n")
   end

   def parse_changes _, flow, *_
      rows = flow.split("* ").map { |p| p.strip }.compact.map { |p| p.split("\n") }

      rows[1..-1].map do |row|
         /(?<date>^\w+\s+\w+\s+\w+\s+\w+)\s+(?<author>.*)\s*(?:<(?<email>.*)>)\s+(?<version>[\w\.]+)(?:-(?<release>[\w\._]+))?$/ =~ row[0]

         {
            date: date,
            author: author.strip,
            email: email,
            version: Gem::Version.new(version),
            release: release,
            description: row[1..-1].join("\n")
         }.to_os
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
      [ { "name" => Setup::Spec::Rpm::Name.parse(context[:name]) }.to_os ]
   end

   def parse_description match, flow, opts, context
      context.replace(parse_context_line(match[1], opts))
      { context[:cp] || "" => flow.split("\n")[1..-1].join("\n") }.to_os
   end

   def parse_license match, *_
      match[1].split(/(?: or |\/)/).map(&:strip)
   end

   def parse_summary match, *_
      { match[1] || "" => match[2] }.to_os
   end

   def parse_context match, *_
      if match[1]
         { "__macros" => { match[1] => match[4] || "#{match[2]} #{match[3]}" }}
      else
         { match[2] => match[3] }
      end
   end

   def parse_version match, *_
      Gem::Version.new(match[1])
   end

   def parse_packager match, *_
      OpenStruct.new(name: match["name"]&.strip, email: match["email"]&.strip)
   end

   def parse_context_line line, opts
      key = nil
      context = line.to_s.split(/\s+/).reduce({}) do |res, arg|
      #binding.pry
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
         opts["secondaries"] ||= []
#         name = Setup::Spec::Rpm::Name.parse(context[:name])
#      binding.pry
#         sel = opts["secondaries"].select { |sec| sec.name == name }

#            opts["secondaries"] << { "name" => name }.to_os if sel.blank?
      end
#      binding.pry

      context
   end

   class << self
      def match? source_in
         MATCHER =~ source_in
      end
   end
end
