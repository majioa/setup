class Setup::Target::Ruby
   attr_reader :home

   def libdir
      spec_path(home && File.join(home, 'lib'), RbConfig::CONFIG['rubylibdir'])
   end

   def lexedir
      lexedir = RbConfig::CONFIG['bindir']

      lexedir != exedir && lexedir || nil
   end

   def exedir
      spec_path(home && File.join(home, 'bin'), RbConfig::CONFIG['bindir'])
   end

   def extdir
      spec_path(home && File.join(home, 'lib'), RbConfig::CONFIG['archdir'])
   end

   def ridir
      spec_path(home && File.join(home, 'doc'), RbConfig::CONFIG['ridir'])
   end

   def datadir
      File.join(RbConfig::CONFIG['datadir'], source.name)
   end

   def confdir
      File.join(RbConfig::CONFIG['sysconfdir'], source.name)
   end

   def specdir
      nil
   end

   def mandir
      RbConfig::CONFIG['mandir']
   end

   def incdir
      RbConfig::CONFIG['includedir']
   end

   def is_lib_separated?
      true
   end

   protected

   def spec_path *args
      args.compact.select { |path| File.exist?(path) }.first
   end

   def initialize home: ENV['MY_RUBY_HOME']
      @home = home || RbConfig::CONFIG['rubylibprefix']
   end
end
