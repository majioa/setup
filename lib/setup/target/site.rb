class Setup::Target::Site
   attr_reader :source, :options

   def root
      source.root
   end

   def public_executables
      @public_executables ||= exefiles.select { |file| source.exefiles.include?(File.basename(file)) }
   end

   # dirs

   def libdir
      File.join(RbConfig::CONFIG['sitelibdir'])
   end

   def lexedir
      nil
   end

   def exedir
      RbConfig::CONFIG['bindir']
   end

   def extdir
      File.join(RbConfig::CONFIG['sitearchdir'])
   end

   def ridir
      File.join(RbConfig::CONFIG['ridir'], source.name)
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

   # files

   def exefiles
      Dir.glob(File.join(chroot, exedir, '*')).map { |file| /^#{chroot}(?<pure>.*)/.match(file)[:pure] }
   end

   def chroot
      options[:chroot] || '/'
   end

   def is_lib_separated?
      true
   end

   protected

   def initialize source: raise, options: {}
      @source = source
      @options = options
   end
end
