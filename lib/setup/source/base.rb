require 'setup/source'

class Setup::Source::Base
   OPTION_KEYS = %i(rootdir replace_list aliases)

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
      "source-ri-folder-lists": :name_or_default,
      "source-inc-folder-lists": :name_or_default,
      "source-ext-folder-lists": :name_or_default,
      "source-lib-folder-lists": :name_or_default,
      "source-app-folder-lists": :name_or_default,
      "source-exe-folder-lists": :name_or_default,
      "source-conf-folder-lists": :name_or_default,
      "source-test-folder-lists": :name_or_default,
      "source-man-folder-lists": :name_or_default,
      "source-sup-folder-lists": :name_or_default,
      "source-data-folder-lists": :name_or_default,
      "source-docsrc-folder-lists": :name_or_default,
      "source-log-folder-lists": :name_or_default,
      "source-state-folder-lists": :name_or_default,
      "source-ri-folders": true,
      "source-inc-folders": true,
      "source-ext-folders": true,
      "source-lib-folders": true,
      "source-app-folders": true,
      "source-exe-folders": true,
      "source-conf-folders": true,
      "source-test-folders": true,
      "source-man-folders": true,
      "source-sup-folders": true,
      "source-data-folders": true,
      "source-docsrc-folders": true,
      "source-log-folders": true,
      "source-state-folders": true,
   }

   attr_reader :rootdir

   class << self
      def opts
         @opts ||= ancestors.reverse.map do |a|
            a.constants.include?(:OPTIONS_IN) &&
            a.const_get(:OPTIONS_IN).to_a ||
            nil
         end.compact.flatten(1).to_os
      end

      def name_for options_in
         fullname = (options_in[:rootdir] || "").split('/').last
         /^(?<name>.*)-([\d\.]+)$/ =~ fullname
         name || fullname
      end

      def source_options options_in = {}.to_os
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

            value
         end.compact.to_os
      end

      def name_or_default value_in, name, source_name
         value = value_in && (value_in[source_name] || value_in[nil]) || nil

         value && [ name.make_singular, value ] || nil
      end

      def rootdir_or_default value_in, name, _
         [ name, value_in || Dir.pwd ]
      end
   end

   def options
      @options ||= {}
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
         fullname || rootdir.split("/").last || "root"
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

   def to_os
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
         rootdir && File.join(rootdir, 'Gemfile.lock') || Tempfile.new('Gemfile.lock').path)
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
      File.file?(File.join(rootdir, file)) && file || nil
   end

   def if_exist file
      File.exist?(File.join(rootdir, file)) && file || nil
   end

   def if_dir dir
      File.directory?(File.join(rootdir, dir)) && dir || nil
   end

   def default_ridir
      ".ri.#{name}"
   end

   def trees &block
      GROUPS.map do |set|
         yield(set, tree(set))
      end
   end

   def compilables
      # TODO make compilables from ext
      extfiles
   end

   # +summaries+ returns an open-struct formatted summaries with a default locale as a key
   # in the spec defined if any, otherwise returns blank open struct.
   #
   # source.summaries # => #<OpenStruct en_US.UTF-8: ...>
   #
   def summaries
      if spec.summary
         { Setup::I18n.default_locale => spec.summary }.to_os
      else
         {}.to_os
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
         [ dir, Dir.chdir(File.join(rootdir, dir)) { Dir.glob('**/**/*') } ]
      end.to_h

      if block_given?
         # TODO deep_merge
         tree_in = tree_in.merge(yield)
      end

      tree_in.map do |dir, files_in|
         files = Dir.chdir(File.join(rootdir, dir)) do
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
