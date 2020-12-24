require 'pry'
require 'shoulda-matchers/cucumber'

Shoulda::Matchers.configure do |config|
   config.integrate do |with|
      with.test_framework :cucumber
   end
end
