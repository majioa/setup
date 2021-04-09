require 'yaml'

module Setup::Actor
   class InvalidActorKindError < StandardError; end
   class InvalidContextKindForActorError < StandardError; end

   AUTOMAP = {
      Spec: "setup/actor/spec",
      Link: "setup/actor/link",
      Touch: "setup/actor/touch",
      Copy: "setup/actor/copy",
   }

   class << self
      def kinds
         list.keys
      end

      def actors
         @actors ||= AUTOMAP.keys.map do |const|
            require(AUTOMAP[const])
            [ const.to_s.downcase, const_get(const) ]
         end.to_h
      end

      def scheme
         @scheme ||= YAML.load(IO.read(File.join(File.dirname(__FILE__), "scheme.erb.yaml")))
      end

      def config
         @config ||= ObjectSpace.each_object(Setup::Configuration).first
      end

      def procline file
         scheme.map.with_index do |rule, index|
            match = rule['match']

            if !match || /#{match}$/ =~ file
               rule['proc'].map do |data|
                  # TODO cache it by match or index
                  context_in = ERB.new(data['context'].to_yaml)
                  c = yield(data['actor'], context_in)
                  c.merge('$' => actors[data['actor']])
               end
            end
         end.compact
      end

      def objectize target
         target.source.trees do |kind, h|
            h.map do |dir, files|
               files.map do |file|
                  procline(file) do |actor, context_in|
                     YAML.load(context_in.result(binding))
                  end
               end
            end
         end.flatten
      end

      def for! task, context
         actor = actors[task.to_s] || raise(InvalidActorKindError)
         actor.context_kind == context.class || raise(InvalidContextKindForActorError)

         actor
      end

      def for task, context
         for!(task, context)
      rescue InvalidActorKindError
      end
   end
end
