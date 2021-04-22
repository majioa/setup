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
      spec_file: nil,
      maintainer_name: nil,
      maintainer_email: nil
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

            opts.on("-i", "--ignore-names=LIST", Array, "Source names comma-separated ignore list") do |list|
               options.ignored_names |= list.compact
            end

            opts.on("-r", "--regard-names=LIST", Array, "Source names comma-separated regard list") do |list|
               options.regarded_names |= list.compact
            end

            opts.on("-o", "--output-file=FILE", String, "Output file for a spec action") do |file|
               options.output_file = file
            end

            opts.on("-s", "--spec-file=FILE", String, "Spec file for covering the setup space") do |file|
               options.spec_file = file
            end

            opts.on("--maintainer-email=EMAIL", String, "Email of the maintainer to use on spec generation") do |email|
               options.maintainer_email = email
            end

            opts.on("-s", "--maintainer-name=NAME", String, "Name of the maintainer to use on spec generation") do |name|
               options.maintainer_name = name
            end

            opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
               options[:verbose] = v
            end

            opts.on("-h", "--help", "This help") do |v|
               puts opts
               exit
            end
         end
   end

   def options
      @options ||= DEFAULT_OPTIONS.dup
   end

   def actions
      @actions ||= parse.actions
   end

   def parse
      return @parse if @parse

      option_parser.default_argv << "-h" if option_parser.default_argv.empty?
      option_parser.parse!

      @parse = OpenStruct.new(options: options, actions: option_parser.default_argv)
   end

   def space
      @space ||= Setup::Space.load_from(options: parse.options)
   end

   def run
      actions.reduce({}.to_os) do |res, action_name|
         res[action_name] = Setup::Actor.for!(action_name, space)

         res
      end.map do |action_name, actor|
         actor.apply_to(space)
      end
   end
end