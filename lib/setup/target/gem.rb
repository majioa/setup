require 'setup/target'

class Setup::Target::Gem
   attr_reader :source, :home, :options

   def root
      chroot
   end

   def public_executables
      @public_executables ||= (lexedir && lexefiles || exefiles).select { |file| source.exefiles.include?(File.basename(file)) }
   end

   # dirs

   def libdir
      File.join(home, 'gems', source.fullname)
   end

   def lexedir
      lexedir = RbConfig::CONFIG['bindir']

      lexedir != exedir && lexedir || nil
   end

   def logdir
      "/var/log/#{source.name}"
   end

   def datadir
      File.join(home, 'gems', source.fullname)
   end

   def exedir
      File.exist?(_exedir) && _exedir || File.join(home, 'gems', source.fullname, 'bin')
   end

   def dldir
      arch = [ ::Gem.platforms.last.cpu, ::Gem.platforms.last.os ].join('-')

      File.join(home, 'extensions', arch, ::Gem.extension_api_version, source.fullname)
   end

   def confdir
      File.join(home, 'gems', source.fullname, 'config')
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
      datadir
   end

   # files

   def exefiles
      Dir.glob(File.join(chroot, exedir, '*')).map { |file| /^#{chroot}(?<pure>.*)/.match(file)[:pure] }
   end

   def lexefiles
      Dir.glob(File.join(chroot, lexedir, '*')).map { |file| /^#{chroot}(?<pure>.*)/.match(file)[:pure] }
   end

   def chroot
      options[:chroot] || '/'
   end

   def is_lib_separated?
      false
   end

   def is_log_separated?
      false
   end

   protected

   def _exedir
      File.join(home, 'gems', source.fullname, 'exe')
   end

   def initialize source: raise, home: ENV['GEM_HOME'] || ::Gem.paths.home, options: {}
      @source = source
      @options = options
      @home = home
   end
end
