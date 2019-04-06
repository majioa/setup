require 'setup/target'

class Setup::Target::Gem
   attr_reader :source, :home, :options

   def root
      chroot
   end

   def public_executables
      @public_executables ||= (lbindir && lbinfiles || binfiles).select { |file| source.binfiles.include?(File.basename(file)) }
   end

   # dirs

   def libdir
      File.join(home, 'gems', source.fullname, source.require_dir)
   end

   def lbindir
      lbindir = RbConfig::CONFIG['bindir']

      lbindir != bindir && lbindir || nil
   end

   def datadir
      File.join(home, 'gems', source.fullname)
   end

   def bindir
      File.exist?(exedir) && exedir || File.join(home, 'gems', source.fullname, 'bin')
   end

   def extdir
      File.join(home, 'extensions', RbConfig::CONFIG["sitearch"], ::Gem.extension_api_version, source.fullname)
   end

   def ridir
      File.join(home, 'doc', source.fullname, 'ri')
   end

   def specdir
      File.join(home, 'specifications')
   end

   def mandir
      RbConfig::CONFIG['mandir']
   end

   def includedir
      RbConfig::CONFIG['includedir']
   end

   # files

   def binfiles
      Dir.glob(File.join(chroot, bindir, '*')).map { |file| /^#{chroot}(?<pure>.*)/.match(file)[:pure] }
   end

   def lbinfiles
      Dir.glob(File.join(chroot, lbindir, '*')).map { |file| /^#{chroot}(?<pure>.*)/.match(file)[:pure] }
   end

   def chroot
      options[:chroot] || '/'
   end

   protected

   def exedir
      File.join(home, 'gems', source.fullname, 'exe')
   end

   def initialize source: raise, home: ENV['GEM_HOME'] || ::Gem.paths.home, options: {}
      @source = source
      @options = options
      @home = home
   end
end
