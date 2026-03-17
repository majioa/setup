class Setup::Source::Fake < Setup::Source::Base
   OPTIONS_IN = {
      source_file: true,
      valid: ->(value_in, _source_name) { value_in.nil? ? true : value_in }
   }

   def dsl
      @dsl ||=
         Setup::DSL.new(source_file,
         replace_list: replace_list,
         skip_list: (options[:gem_skip_list] || []) | [self.name],
         append_list: options[:gem_append_list])
   end

   def tree *_
      []
   end

   def valid?
      @valid
   end
end
