class Setup::Target::Site
   attr_reader :source, :options

   def root
      source.root
   end

   def public_executables
      @public_executables ||= binfiles.select { |file| source.binfiles.include?(File.basename(file)) }
   end

   # dirs

   def libdir
      File.join(RbConfig::CONFIG['sitelibdir'], source.name)
   end

   def lbindir
      nil
   end

   def bindir
      RbConfig::CONFIG['bindir']
   end

   def extdir
      File.join(RbConfig::CONFIG['sitearchdir'], source.name)
   end

   def ridir
      File.join(RbConfig::CONFIG['ridir'], source.name)
   end

   def specdir
      nil
   end

   def mandir
      RbConfig::CONFIG['mandir']
   end

   # files

   def binfiles
      Dir.glob(File.join(chroot, bindir, '*')).map { |file| /^#{chroot}(?<pure>.*)/.match(file)[:pure] }
   end

   def chroot
      options[:chroot] || '/'
   end

   protected

   def initialize source: raise, options: {}
      @source = source
      @options = options
   end
end
