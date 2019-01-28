class Setup::Source::Root
   attr_reader :root

   class << self
      def search dir, _ = {}
         self.new(root: dir)
      end
   end

   def gemfile
      @gemfile ||= root && (
         file = "#{root}/Gemfile"
         File.exist?(file) && file) || nil
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

   def doc_sourcedirs
      %w(app config).select { |file| File.directory?(file) }
   end

   # dirs

   def libdir
      @libdir ||= 'lib'
   end

   def bindir
      @bindir ||= exedir || 'bin'
   end

   def extdir
      @extdir ||= '.'
   end

   def ridir
      @ridir ||= ".ri.#{name}"
   end

   def dldir
      extdir
   end

   def mandir
      @mandir ||= mandirs.first
   end

   def mandirs
      @mandirs ||= %w(man Documentation doc).select do |dir|
         File.directory?(File.join(root, dir))
      end
   end

   # files

   def libfiles
      @libfiles ||= (
         dir = File.join(root, libdir)

         if File.exist?(dir)
           Dir.chdir(dir) do
             Dir.glob("*/**/*.rb").select { |file| File.file?(file) }
           end
         end || [])
   end

   def rifiles
      @rifiles ||= (
         dir = File.join(root, ridir)

         if File.exist?(dir)
           Dir.chdir(dir) do
             Dir.glob("**/*.ri").select { |file| File.file?(file) }
           end
         end || [])
   end

   def extfiles
      []
   end

   def dlfiles
      []
   end

   def binfiles
      @binfiles ||= (
         dir = File.join(root, bindir)

         if File.exist?(dir)
            Dir.chdir(dir) do
               Dir.glob("**/*").select { |file| File.file?(file) }
            end
         end || [])
   end

   def manfiles
      @manfiles ||= !mandirs.empty? && (
         Dir.chdir(root) do
            Dir.glob("#{mandirs.join(',')}/**/*.{1,2,3,4,5,6,7,8}").select { |file| File.file?(file) }
         end) || []
   end

   def datafiles
      []
   end

   def includefiles
      []
   end

   def doc_sourcefiles
      doc_sourcedirs
   end

   # custom

   def extroot_for file
      extroots.find { |extroot| extroot == file[0...extroot.size] }
   end

   # questionaries

   def valid?
      !gemfile.nil?
   end

   def compilable?
      extfiles.any?
   end

   def to_h
      {
         type: 'root',
         root: root,
      }
   end

   protected

   def extroots
      @extroots ||= extfiles.map { |extfile| File.dirname(extfile) }
   end

   def dlext
      RbConfig::CONFIG['DLEXT']
   end

   def exedir
      @exedir ||= File.join(root, 'exe')
   end

   #
   def initialize(root: Dir.pwd)
      @root = root
   end
end
