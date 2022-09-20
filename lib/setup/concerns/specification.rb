require 'setup/concerns'

module Setup::Concerns::Specification
   class << self
      def included mod_in
         mod_in.define_method(:rubyforge_project=) { |_| }
      end
   end

   def merge other_spec
      new = self.dup

      new.instance_variables.each do |var_name|
         value = new.instance_variable_get(var_name)

         new_value =
            case value
            when Array
               other_array = (other_spec.instance_variable_get(var_name) rescue []) || []

               [value, other_array].flatten(1).uniq
            when Hash
               other_hash = (other_spec.instance_variable_get(var_name) rescue {}) || {}

               other_hash.merge(value)
            when NilClass
               other_spec.instance_variable_get(var_name) rescue nil
            else
               value
            end

         new.instance_variable_set(var_name, new_value)
      end

      new
   end
end
