require 'setup/source'

class Setup::Source::Base
   OPTION_KEYS = %i(root replace_list aliases)

   DL_DIRS     = ->(s) { ".so.#{s.name}#{RbConfig::CONFIG['sitearchdir']}" }
   RI_DIRS     = ->(s) { [ s.default_ridir, 'ri' ] }
   INC_DIRS    = %w(ext)
   EXT_DIRS    = %w(ext)
   LIB_DIRS    = %w(lib)
   APP_DIRS    = %w(app webpack script public)
   EXE_DIRS    = %w(bin exe)
   CONF_DIRS   = %w(etc config conf)
   TEST_DIRS   = %w(tests test spec features acceptance autotest)
   MAN_DIRS    = %w(doc docs Documentation man docs-source)
   SUP_DIRS    = %w(util yardoc benchmarks examples .git tmp vendor sample)
   DATA_DIRS   = %w(.)
   DOCSRC_DIRS = ->(s) { s.libdirs | s.appdirs | s.exedirs | s.confdirs }

   DL_RE       = ->(_) { /\.(#{RbConfig::CONFIG['DLEXT']}|build_complete)$/ }
   RI_RE       = /\.ri$/
   INC_RE      = /\.(h|hpp)$/
   MAN_RE      = /\.[1-8](.ronn)?$/
   EXT_RE      = /\bextconf.rb$/
   DATA_RE     = ->(s) do
         dirs = s.extdirs | s.libdirs | s.appdirs | s.exedirs |
            s.confdirs | s.testdirs | s.mandirs | s.supdirs |
            s.ridirs | s.dldirs | s.incdirs

         dirs.empty? && /.*/ || /^(?!.*#{dirs.join('\b|').gsub('.', '\\\\.')}\b)/
end
   DOCSRC_RE = /\.rb$/

   GROUPS = constants.select { |c| c =~ /_DIRS/ }.map { |c| c.to_s.sub('_DIRS', '').downcase }

   PASSIN_OPTIONS = {
      aliases: ->(o, name) { o.is_a?(Hash) && [ o[nil], o[name] ].flatten.compact.uniq || o },
      version_replaces: true,
      gem_version_replace: true,
      spec: true,
      root: true
   }

   PROC_OPTIONS = %i(srcridirs srcincdirs srcextdirs srclibdirs srcappdirs srcexedirs
                     srcconfdirs srctestdirs srcmandirs srcsupdirs srcdatadirs srcdocsrcdirs)

   attr_reader :options

   class << self
      def name_for options_in
         fullname = (options_in[:root] || "").split('/').last
         /^(?<name>.*)-([\d\.]+)$/ =~ fullname
         name || fullname
      end

      def source_options options_in = {}
         name = name_for(options_in)

         parsed = PROC_OPTIONS.map do |oname|
            onames = oname.pluralize
            opt = options_in[onames]
            value = opt && (opt[name] || opt[nil]) || nil

            value && [ oname, value ] || nil
         end.compact.to_h

         PASSIN_OPTIONS.map do |oname, rule|
            value_in = options_in[oname]

            value = case rule
            when true
               value_in
            when Proc
               rule[value_in, name]
            else
               nil
            end

            value && [ oname, value ] || nil
         end.compact.to_h.merge(parsed)
      end
   end

   def fullname
      @fullname ||= root.split('/').last
   end

   def name
      @name ||= (
         /^(?<name>.*)-([\d\.]+)$/ =~ fullname
         name || fullname)
   end

   def version
      @version ||= (
         /-(?<version>[\d\.]+)$/ =~ fullname
         version)
   end

   def root
      options[:root]
   end

   def dsl
      options[:dsl]
   end

   def replace_list
      options[:replace_list]
   end

   def aliases
      options[:aliases]
   end

   # dirs
   #
   GROUPS.each do |kind|
      func = <<-DEF
         def #{kind}dirs &block
            @#{kind}dirs ||= dirs(:#{kind}, options[:src#{kind}dirs], &block)
         end
      DEF

      eval(func)
   end

   # files
   #
   GROUPS.each do |kind|
      func = <<-DEF
         def #{kind}files &block
            @#{kind}files ||= files(:#{kind}, &block)
         end
      DEF

      eval(func)
   end

   # tree
   #
   GROUPS.each do |kind|
      func = <<-DEF
         def #{kind}tree &block
            @#{kind}tree ||= tree(:#{kind}, &block)
         end
      DEF

      eval(func)
   end

   # questionaries

   def valid?
      false
   end

   def compilable?
      extfiles.any?
   end

   def to_h
      options.merge(type: type)
   end

   def type
      self.class.to_s.split('::').last.downcase
   end

   def required_rubygems_version
      ">= 0"
   end

   def required_ruby_version
      Gem::Requirement.new(dsl&.instance_variable_get(:@ruby_version)&.engine_versions) || ">= 0"
   end

   def required_ruby
      dsl&.instance_variable_get(:@ruby_version)&.engine || "ruby"
   end

   def lockfile
      @lockfile ||= (
         root && File.join(root, 'Gemfile.lock') || Tempfile.new('Gemfile.lock').path)
   end

   def definition
      dsl&.dsl&.to_definition(lockfile, true)
   end

   def deps groups_in = nil
      groups = groups_in && (
         [ groups_in ].flatten.map { |g| g == :runtime && (definition.groups - %i(development test)) || group }.flatten
         ) || definition.groups

      definition.dependencies.select do |dep|
         (dep.groups & groups).any? && dep.should_include? && !dep.autorequire&.all?
      end
   end

   def has_name? name
      self.name == name || aliases && aliases.include?(name)
   end

   def if_file file
      File.file?(File.join(root, file)) && file || nil
   end

   def if_exist file
      File.exist?(File.join(root, file)) && file || nil
   end

   def if_dir dir
      File.directory?(File.join(root, dir)) && dir || nil
   end

   def default_ridir
      ".ri.#{name}"
   end

   protected

   def exedir
      @exedir ||= if_exist('exe')
   end

   def dirs kind, dirs_in = nil, &block
      dirlist_am = [
         dirs_in,
         options[:"src#{kind}dirs"],
         self.class.const_get("#{kind.upcase}_DIRS")
      ].compact.first

      [ dirlist_am ].flatten.map do |dir_am|
         file = dir_am.is_a?(Proc) ? dir_am[self] : dir_am
      end.flatten.compact.select { |file| if_dir(file) }
   end

   def tree kind, &block
      re_in = self.class.const_get("#{kind.upcase}_RE") rescue nil
      re = re_in.is_a?(Proc) && re_in[self] || re_in || /.*/

      tree_in = send("#{kind}dirs").map do |dir|
         [ dir, Dir.chdir(File.join(root, dir)) { Dir.glob('**/**/*') } ]
      end.to_h

      if block_given?
         # TODO deep_merge
         tree_in = tree_in.merge(yield)
      end

      tree_in.map do |dir, files_in|
         files = Dir.chdir(File.join(root, dir)) do
            files_in.select do |file|
               re =~ file && File.file?(file)
            end
         end

#         require 'pry';binding.pry #if kind == 'lib'

         [ dir, files ]
      end.to_h
   end

   def files kind, &block
      send("#{kind}tree", &block).map { |(_, values)| values }.flatten
   end

   #
   def initialize options_in = {}
      @options = { root: Dir.pwd,
                   replace_list: {} }.merge(options_in)
   end
end
