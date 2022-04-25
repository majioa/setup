require 'setup'
require 'rake'

module Setup::Loader
   module Certain
      include(Rake::DSL)

      attr_reader :object_hash, :object_ids

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
            @object_ids = object_hash.map do |(k, oh)|
               [k, oh.map {|h| h.__id__ } - @object_hash[k].map {|h| h.__id__ }]
            end.to_h
         end

         @object_hash = object_hash
      end

      def load_file file, type_hash
         # NOTE this forces not to share namespace but avoid exception when calling
         # main space methods, see Rakefile of racc gem
         # also named module is required instead of anonymous one to allow root level defined methods access
         store_object_hash(type_hash)

         begin
            Dir.chdir(File.dirname(file)) do
               load(File.basename(file), true)
            end
         rescue Exception => e
            raise e
         ensure
            store_object_hash(type_hash)
         end

         self
      rescue Exception => e
         $stderr.puts("[#{e.class}]: #{e.message}\n\t#{e.backtrace.join("\n\t")}")

         self
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
      @@mods ||= {}
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
      $stdout.rewind
      $stderr.rewind
      log = $stdout.readlines
      errlog = $stderr.readlines

      OpenStruct.new(mod: mod, log: log, errlog: errlog, object_hash: mod.object_hash, diff_ids: mod.object_ids)
   rescue Exception => e
      warn(e.message)
      OpenStruct.new(mod: mod, object_hash: {}, log: log, errlog: errlog, diff_ids: [])
   ensure
      $stderr = stderr
      $stdout = stdout
   end

   def app_file file, &block
      mods[file] ||= load_file(file)

      mod = mods[file].dup
      objects = mod.diff_ids[self]&.map {|id| ObjectSpace._id2ref(id) }
      if block_given?
         objects = [yield(objects)].flatten.compact
      end
      mod.objects = objects || []

      mod
   end
end
