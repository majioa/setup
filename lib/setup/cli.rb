require 'optparse'
require 'ostruct'
require 'yaml'

require 'setup'
require 'setup/space'
require 'setup/actor'
require 'setup/log'

class Setup::CLI
   include Setup::Log

   DEFAULT_OPTIONS = {
      rootdir: Dir.pwd,
      spec_type: "rpm",
      ignored_names: [],
      regarded_names: [],
      aliased_names: [],
      ignored_path_tokens: [],
      spec_file: nil,
      maintainer_name: nil,
      maintainer_email: nil,
      available_gem_list: {},
      devel_dep_setup: :include,
      use_gem_version_list: {}.to_os,
      log_level: :info,
      warn_io: 'stderr',
      error_io: 'stderr',
      info_io: 'stdout',
      debug_io: 'stderr',
      skip_platforms: %i(jruby)
   }.to_os

   def option_parser
      @option_parser ||=
         OptionParser.new do |opts|
            opts.banner = "Usage: setup.rb [options & actions]"

            opts.on("-r", "--rootdir=FOLDER", String, "Root folder to scan the sources") do |folder|
               options[:rootdir] = folder
            end

            opts.on("--source-lib-folders=FOLDERS", Array, "Lib directories for the current source or at whole") do |list|
               options[:source_lib_folders] = list.compact
            end

            opts.on("-I", "--ignore-names=LIST", Array, "Source names comma-separated ignore list") do |list|
               options.ignored_names |= list.compact.map do |x|
                  m = /^\/(?<re>.*)/.match(x)
                  m && /#{m[:re]}/ || x
               end
            end

            opts.on("-R", "--regard-names=LIST", Array, "Source names comma-separated regard list") do |list|
               options.regarded_names |= list.compact.map do |x|
                  m = /^\/(?<re>.*)/.match(x)
                  m && /#{m[:re]}/ || x
               end
            end

            opts.on("-A", "--alias-names=[LIST]", Array, "Source names comma-separated alias list") do |list|
               options.aliased_names << list.compact
            end

            opts.on("-o", "--output-file=FILE", String, "Output file for a spec action") do |file|
               options.output_file = file
            end

            opts.on("-s", "--spec-file=FILE", String, "Spec file for covering the setup space") do |file|
               options.spec_file = file
            end

            opts.on("-i", "--ignore-path-tokens=[LIST]", Array, "Ignore sources by a contained in its path token, and passed as a comma-separated list") do |list|
               options.ignored_path_tokens.concat(list.compact)
            end

            opts.on("--maintainer-name=NAME", String, "Name of the maintainer to use on spec generation") do |name|
               options.maintainer_name = name
            end

            opts.on("--maintainer-email=EMAIL", String, "Email of the maintainer to use on spec generation") do |email|
               options.maintainer_email = email
            end

            opts.on("--devel-dep-setup=<TYPE>", %i(include skip), "Apply setup type for devel dependencies to use with, defaulting to 'include'") do |type|
               options.devel_dep_setup = type
            end

            opts.on("-g", "--available-gem-list-file=[FILE]", String, "Path to a YAML-formatted file with the list of available gems to replace in dependencies") do |file|
               options.available_gem_list = YAML.load(IO.read(file))
            end

            opts.on("--debug-io=[FILE|IO| |-|--]", String, "IO for debug level. Value is file name, or --/stderr for stderr, or -/stdout for stdout, or blank to disable") do |str|
               options.debug_io = str
            end

            opts.on("-V", "--use-gem-version=[LIST]", Array, "Comma separated gem version pair list to forcely use in the setup") do |gem_version|
               hash = gem_version.map {|gv| gv.split(":") }.to_h
               options.use_gem_version_list = options.use_gem_version_list.merge(hash)
            end

            opts.on("-v", "--verbose=[LEVEL]", String, "Run verbosely with levels: none, error, warn, info, or debug") do |v|
               options.log_level = v
            end

            opts.on("-h", "--help", "This help") do |v|
               puts opts
               exit
            end
         end

      if @argv
         @option_parser.default_argv.replace(@argv)
      elsif @option_parser.default_argv.empty?
         @option_parser.default_argv << "-h"
      end

      @option_parser
   end

   def options
      @options ||= DEFAULT_OPTIONS.dup
   end

   def actions
      @actions ||= parse.actions.select { |a| Setup::Actor.kinds.include?(a) }
   end

   def parse!
      return @parse if @parse

      option_parser.parse!

      @parse = OpenStruct.new(options: options, actions: option_parser.default_argv)
   end

   def parse
      parse!
   rescue OptionParser::InvalidOption
      @parse = OpenStruct.new(options: options, actions: option_parser.default_argv)
   end

   def space
      @space ||= Setup::Space.load_from(nil, parse.options)
   end

   def space= value
      @space = value
   end

   def run
      actions.reduce({}.to_os) do |res, action_name|
         res[action_name] = Setup::Actor.for!(action_name, space)

         res
      end.map do |action_name, actor|
         actor.apply_to(space)
      end
   rescue SystemExit, Interrupt
   rescue Exception => e
      binding.pry
      error("[#{e.class}]: #{e.message}\n\t#{e.backtrace.join("\n\t")}")
   end

   def initialize argv = nil
      @argv = argv&.split(/\s+/)
   end
end
