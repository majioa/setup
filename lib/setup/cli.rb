require 'optparse'
require 'ostruct'

require 'setup'
require 'setup/space'
require 'setup/actor'

class Setup::CLI
   DEFAULT_OPTIONS = {
      rootdir: Dir.pwd,
      spec_type: "rpm",
      ignored_names: [],
      regarded_names: [],
      aliased_names: [],
      spec_file: nil,
      maintainer_name: nil,
      maintainer_email: nil,
      available_gem_list: {},
      devel_dep_setup: :include,
      use_gem_version_list: {}.to_os,
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
               options.ignored_names |= list.compact
            end

            opts.on("-R", "--regard-names=LIST", Array, "Source names comma-separated regard list") do |list|
               options.regarded_names |= list.compact
            end

            opts.on("-A", "--alias-names=LIST", Array, "Source names comma-separated alias list") do |list|
               options.aliased_names << list.compact
            end

            opts.on("-o", "--output-file=FILE", String, "Output file for a spec action") do |file|
               options.output_file = file
            end

            opts.on("-s", "--spec-file=FILE", String, "Spec file for covering the setup space") do |file|
               options.spec_file = file
            end

            opts.on("--maintainer-name=NAME", String, "Name of the maintainer to use on spec generation") do |name|
               options.maintainer_name = name
            end

            opts.on("--maintainer-email=EMAIL", String, "Email of the maintainer to use on spec generation") do |email|
               options.maintainer_email = email
            end

            opts.on("--devel-dep-setup=[TYPE]", %i(include skip), "Apply setup type for devel dependencies to use with, defaulting to 'include'") do |type|
               options.devel_dep_setup = type
            end

            opts.on("-g", "--available-gem-list-file=FILE", String, "Path to a YAML-formatted file with the list of available gems to replace in dependencies") do |file|
               options.available_gem_list = YAML.load(IO.read(file))
            end

            opts.on("-V", "--use-gem-version=GEM_VERSION", String, "Gem version pair to forcely use in the setup") do |gem_version|
               hash = gem_version.split(",").map {|gv| gv.split(":") }.to_h
               options.use_gem_version_list = options.use_gem_version_list.merge(hash)
            end

            opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
               options[:verbose] = v
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
   end

   def initialize argv = nil
      @argv = argv&.split(/\s+/)
   end
end
