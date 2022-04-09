require 'setup'

module Setup::Source
   KINDS = %i(Gem Gemfile Rakefile)

   class << self
      def search dir, options = {}
         KINDS.map do |const|
            self.const_get(const).search(dir, options)
         end.flatten.group_by do |source|
            source.root
         end.map do |_a, sources_in|
            ina = sources_in.select {|s| KINDS[-1] == s.class.to_s.split("::").last.to_sym }

            KINDS.reverse[1..-1].reduce(ina) do |res, kind|
               selected =
                  sources_in.select do |s|
                     KINDS[KINDS.index(kind)] == s.class.to_s.split("::").last.to_sym
                  end

               selected.any? && selected.map {|v| ([v] | res).reduce(&:+) } || res
            end
         end.flatten
      end
   end
end

require 'setup/source/gem'
require 'setup/source/rakefile'
require 'setup/source/gemfile'
