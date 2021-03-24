require 'pry'
require 'shoulda-matchers/cucumber'
require 'timecop'

require 'setup'

Shoulda::Matchers.configure do |config|
   config.integrate do |with|
      with.test_framework :cucumber
   end
end

After do
   Timecop.return
end
