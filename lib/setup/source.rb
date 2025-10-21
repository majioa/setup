require 'setup'

module Setup::Source
   TYPES =
      %w(Gem Gemfile Rakefile Fake Base).reduce({}) do |types, name|
         autoload(:"#{name}", File.dirname(__FILE__) + "/source/#{name.downcase}")
         types.merge(name.downcase.to_sym => "Setup::Source::#{name}")
      end

   class << self
      # returns all the found sources with their statuses, and sorted by their root value
      #
      def search dir_in, options = {}
         dir = File.expand_path(dir_in)
         sources_pre =
            TYPES.map do |(name, const)|
               kls = self.const_get(const)
               kls.respond_to?(:search) && kls.search(dir, options.dup) || []
            end.flatten | [ self::Fake.new({ source_file: File.join(dir, '.fake') }.to_os) ]

         sources_pre.group_by do |source|
            source.root
         end.map do |_a, sources_in|
            ina = sources_in.select {|s| TYPES.keys[-1] == s.class.to_s.split("::").last.downcase.to_sym }

            TYPES.keys.reverse[1..-1].reduce(ina) do |res, kind|
               selected =
                  sources_in.select do |s|
                     TYPES.keys[TYPES.keys.index(kind)] == s.class.to_s.split("::").last.downcase.to_sym
                  end

               selected.any? && selected.map {|v| ([v] | res).reduce(&:+) } || res
            end
         end.flatten
      end

      def loaders
         @loaders ||=
            TYPES.map do |type, mod|
               if mod.constantize.constants.include?(:LOADERS)
                  mod.constantize.const_get(:LOADERS).values
               else
                  type
               end
            end.flatten.uniq
      end
   end
end

require 'setup/source/gem'
require 'setup/source/rakefile'
require 'setup/source/gemfile'
