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

   def logdir
      "/var/log/#{source.name}"
   end

   def exedir
      RbConfig::CONFIG['bindir']
   end

   def dldir
      File.join(RbConfig::CONFIG['sitearchdir'])
   end

   def ridir
      File.join(RbConfig::CONFIG['ridir'], source.name)
   end

   def datadir
      File.join(RbConfig::CONFIG['libexecdir'], source.name)
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

   def appdir
      datadir
   end

   def testdir
      datadir
   end

   def supdir
      datadir
   end

   def statedir
      File.join(RbConfig::CONFIG['localstatedir'], source.name)
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

   def is_log_separated?
      libdir && libdir != logdir
   end

   protected

   def initialize source: raise, options: {}
      @source = source
      @options = options
   end
end
