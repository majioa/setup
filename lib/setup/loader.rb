require 'setup'
require 'rake'

module Setup::Loader
   module Certain
      include(Rake::DSL)

      def store_object_hash type_hash
         object_hash =
            type_hash.map do |(klass, types)|
               objects = types.split(',').map do |type|
                  begin
                     ObjectSpace.each_object(type.constantize).map { |h| h }
                  rescue NameError
                     []
                  end
               end.flatten

               [klass, objects]
            end.to_h

         if @object_hash
            @object_hash = object_hash.map do |(k, oh)|
               [k, oh - @object_hash[k]]
            end.to_h
         else
            @object_hash = object_hash
         end
      end

      def load_file file, type_hash
         # NOTE this forces not to share namespace but avoid exception when calling
         # main space methods, see Rakefile of racc gem
         # also named module is required instead of anonymous one to allow root level defined methods access
         store_object_hash(type_hash)

         Dir.chdir(File.dirname(file)) do
            load(File.basename(file), true)
         end

         store_object_hash(type_hash)

         self
      end

      def object_hash
         @object_hash
      end
   end

   def self.extended_list
      @extended_list ||= []
   end

   def self.extended kls
      extended_list << kls
   end

   def type_hash
      @type_hash ||=
         Setup::Loader.extended_list.map do |kls|
            type =
               begin
                  kls.const_get('TYPE')
               rescue
                  nil
               end

            [kls, type]
         end.select {|(_, type)| type }.to_h
   end

   def mods
      @mods ||= {}
   end

   def load_file file
      stdout = $stdout
      stderr = $stderr
      $stdout = $stderr = Tempfile.new('loader')

      module_name = "M" + Random.srand.to_s
      mod_code = <<-END
         module #{module_name}
            extend(::Setup::Loader::Certain)
         end
      END

      mod = module_eval(mod_code)
      mod.load_file(file, type_hash)
      log = $stdout.readlines
      errlog = $stderr.readlines

      OpenStruct.new(mod: mod, log: log, errlog: errlog, object_hash: mod.object_hash)
   rescue Exception => e
      warn(e.message)
      OpenStruct.new(objects: [])
   ensure
      $stderr = stderr
      $stdout = stdout
   end

   def app_file file, &block
      mods[file] ||= load_file(file)

      mod = mods[file].dup
      objects = mod.object_hash[self]
      if block_given?
         objects = [yield(objects)].flatten.compact
      end
      mod.objects = objects

      mod
   end
end
