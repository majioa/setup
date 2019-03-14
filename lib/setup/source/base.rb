require 'setup/source'

class Setup::Source::Base
   attr_reader :root

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
      %w(app lib config).select { |file| if_exist(file) }
   end

   # dirs

   def etcdir
      @etcdir ||= if_exist('etc')
   end

   def libdir
      @libdir ||= if_exist('lib')
   end

   def datadir
      '.'
   end

   def bindir
      @bindir ||= exedir || if_exist('bin')
   end

   def extdir
      @extdir
   end

   def ridir
      @ridir ||= ".ri.#{name}"
   end

   def dldir
      extdir
   end

   def mandir
      @mandir ||= %w(man Documentation doc).find { |dir| if_exist(dir) }
   end

   def includedir
      extdir
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

   def datafiles
      []
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

   def includefiles
      []
   end

   def doc_sourcefiles
      doc_sourcedirs
   end

   # questionaries

   def valid?
      false
   end

   def compilable?
      extfiles.any?
   end

   def to_h
      {
         type: type,
         root: root,
      }
   end

   def type
      self.class.to_s.split('::').last.downcase
   end

   protected

   def if_exist dir
      File.directory?(dir) && dir || nil
   end

   def dlext
      RbConfig::CONFIG['DLEXT']
   end

   def exedir
      @exedir ||= if_exist('exe')
   end

   #
   def initialize(root: Dir.pwd)
      @root = root
   end
end
