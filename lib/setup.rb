begin
   require 'pry'
rescue LoadError
end

require 'setup/version'
# Load concerns
Dir[File.join(File.dirname(__FILE__), 'setup', 'concerns', '*.rb')].each { |d| require(d) }

#require 'setup/session'
require 'setup/core_ext'
require 'setup/deps'
require 'setup/dsl'
require 'setup/i18n'
require 'setup/source'
require 'setup/target'
require 'setup/gemspec'
require 'setup/space'
require 'setup/spec'
require 'setup/actor'

module Setup
   Kernel.define_method(:t) { |*args| Setup::I18n.t(*args) }
end
