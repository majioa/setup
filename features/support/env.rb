require 'pry'
require 'shoulda-matchers/cucumber'

require 'setup'

Shoulda::Matchers.configure do |config|
   config.integrate do |with|
      with.test_framework :cucumber
   end
end
