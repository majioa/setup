require 'pry'
require 'shoulda-matchers/cucumber'
require 'timecop'

require 'setup'
require 'setup/cli'

Shoulda::Matchers.configure do |config|
   config.integrate do |with|
      with.test_framework :cucumber
   end
end

After do
   instance_variables.reject do |name|
      name.to_s =~ /__/
   end.each do |name|
      instance_variable_set(name, nil)
   end

   Timecop.return
end
