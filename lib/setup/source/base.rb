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
   SUP_DIRS    = %w(util yardoc benchmarks examples .git vendor sample)
   LOG_DIRS    = %w(log)
   DATA_DIRS   = %w(.)
   STATE_DIRS  = %w(tmp)
   DOCSRC_DIRS = ->(s) { s.libdirs | s.appdirs | s.exedirs | s.confdirs }

   DL_RE       = ->(_) { /\.(#{RbConfig::CONFIG['DLEXT']}|build_complete)$/ }
   RI_RE       = /\.ri$/
   INC_RE      = /\.(h|hpp)$/
   MAN_RE      = /\.[1-8](.ronn)?$/
   EXT_RE      = /\bextconf.rb$/
   DATA_RE     = ->(s) do
         dirs = s.extdirs | s.libdirs | s.appdirs | s.exedirs |
            s.confdirs | s.testdirs | s.mandirs | s.supdirs |
            s.ridirs | s.dldirs | s.incdirs | s.logdirs | s.statedirs

         dirs.empty? && /.*/ || /^(?!.*#{dirs.join('\b|').gsub('.', '\\\\.')}\b)/
      end
   DOCSRC_RE = /\.rb$/

   GROUPS = constants.select { |c| c =~ /_DIRS/ }.map { |c| c.to_s.sub('_DIRS', '').downcase }

   OPTIONS_IN = {
      aliases: ->(o, name) { o.is_a?(Hash) && [ o[nil], o[name] ].flatten.compact.uniq || o },
      version_replaces: true,
      gem_version_replace: true,
      rootdir: :rootdir_or_default,
      srcridirses: :name_or_default,
      srcincdirses: :name_or_default,
      srcextdirses: :name_or_default,
      srclibdirses: :name_or_default,
      srcappdirses: :name_or_default,
      srcexedirses: :name_or_default,
      srcconfdirses: :name_or_default,
      srctestdirses: :name_or_default,
      srcmandirses: :name_or_default,
      srcsupdirses: :name_or_default,
      srcdatadirses: :name_or_default,
      srcdocsrcdirses: :name_or_default,
      srclogdirses: :name_or_default,
      srcstatedirses: :name_or_default,
      srcridirs: true,
      srcincdirs: true,
      srcextdirs: true,
      srclibdirs: true,
      srcappdirs: true,
      srcexedirs: true,
      srcconfdirs: true,
      srctestdirs: true,
      srcmandirs: true,
      srcsupdirs: true,
      srcdatadirs: true,
      srcdocsrcdirs: true,
      srclogdirs: true,
      srcstatedirs: true,
   }

   attr_reader :rootdir

   class << self
      def opts
         @opts ||= ancestors.reverse.map do |a|
            a.constants.include?(:OPTIONS_IN) &&
            a.const_get(:OPTIONS_IN).to_a ||
            nil
         end.compact.flatten(1).to_h
      end

      def name_for options_in
         fullname = (options_in[:root] || "").split('/').last
         /^(?<name>.*)-([\d\.]+)$/ =~ fullname
         name || fullname
      end

      def source_options options_in = {}
         source_name = name_for(options_in)

         opts.map do |name_in, rule|
            value_in = options_in[name_in.to_s]

            name, value = case rule
               when true
                  [name_in, value_in]
               when Proc
                  [name_in, rule[value_in, source_name] ]
               when Symbol
                  method(rule)[value_in, name_in, source_name]
               else
                  nil
               end

            value && [ name, value ] || nil
         end.compact.to_h
      end

      def name_or_default value_in, name, source_name
         value = value_in && (value_in[source_name] || value_in[nil]) || nil

         value && [ name.make_singular, value ] || nil
      end

      def rootdir_or_default value_in, name, _
         [ name, value_in || Dir.pwd ]
      end
   end

   # +fullname+ returns full name of the source, by default it is the name of the current folder,
   # if it is the root folder the name is "root".
   # A mixin can redefine the method to return the proper value
   #
   # source.name #=> "source_name"
   #
   def fullname
      @fullname ||= rootdir.split('/').last || "root"
   end

   # +name+ returns dynamically detected name of the source base on the fullname,
   # in case the fullname is detected in a format of <name-version>, the <name> is returned,
   # otherwise the full name is returned itself.
   # A mixin can redefine the method to return the proper value
   #
   # source.name #=> "source_name"
   #
   def name
      return @name if @name

      if /^(?<name>.*)-([\d\.]+)$/ =~ fullname
         name
      else
         fullname
      end
   end

   # +version+ returns version of the source by default it is the daystamp for today,
   # A subslass can redefine the method to return the proper value
   #
   # source.version #=> "20000101"
   # source.version #=> "2.1.0"
   #
   def version
      return @version if @version

      if /-(?<version>[\d\.]+)$/ =~ fullname
         version
      else
         Time.now.strftime("%Y%m%d")
      end
   end

   def dsl
      @dsl ||= options[:dsl] || Setup::DSL.new(source: self)
   end

   def replace_list
      @gem_version_replace
   end

   def aliases
      @aliases
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
      groups = groups_in && ([ groups_in ].flatten.map do |g|
            g == :runtime && (definition.groups - %i(development test)) || group
         end.flatten) || definition.groups

      definition.dependencies.select do |dep|
         (dep.groups & groups).any? &&
          dep.should_include? # &&
         # (dep.autorequire || [ true ]).all? { |r| r }
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

   def trees &block
      GROUPS.map do |set|
         yield(set, tree(set))
      end
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

         # require 'pry';binding.pry if kind == :exe

         [ dir, files ]
      end.to_h
   end

   def files kind, &block
      send("#{kind}tree", &block).map { |(_, values)| values }.flatten
   end

   #
   def initialize options_in = {}
      parse(options_in)
   end

   def parse options_in
      self.class.source_options(options_in).each do |option, value|
         instance_variable_set(:"@#{option}", value)
      end
   end
end
