Given('options for Setup CLI:') do |text|
   ARGV.replace(text.split(/\s+/))
   cli.option_parser.default_argv = text.split(/\s+/)
end

Given('blank setup CLI') do
   @cli = nil
end

Given('the default option for {string} is {string}') do |name, value|
   cli.options[name] = value
end

When('developer loads setup.rb') do
   cli.run
end

Then('property {string} of space is blank') do |property|
   expect(space.send(property)).to be_blank
end

Then('property {string} of space matches to:') do |property, text|
   expect(space.send(property)).to match(text.split("\n"))
end

Then('space\'s property {string} is:') do |property, text|
   value = property.split(".").reduce(space) do |object, sub|
      sub =~ /^\d+$/ && object[sub.to_i] || object.send(sub)
   end

   expect(value).to eql(text)
end

Then('property {string} of options is {string}') do |property, value|
   expect(space.options.send(property)).to eql(value)
end
