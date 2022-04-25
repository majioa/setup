class Setup::Source::Fake < Setup::Source::Base
   def dsl
      @dsl ||= Setup::DSL.new(source_file,
                              replace_list: replace_list,
                              skip_list: (options[:gem_skip_list] || []) | [self.name],
                              append_list: options[:gem_append_list])
   end

   def valid?
      true
   end
end
