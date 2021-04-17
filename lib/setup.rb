require 'setup/version'
# Load concerns
Dir[File.join(File.dirname(__FILE__), 'setup', 'concerns', '*.rb')].each { |d| require(d) }

require 'setup/session'
require 'setup/source'
require 'setup/target'
require 'setup/gemspec'
require 'setup/space'
require 'setup/spec'
require 'setup/actor'

