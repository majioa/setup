# vim:setl sw=3 sts=3 ts=3 et:
Given('RPM spec file:') do |rpm_spec|
   @spec_in = StringIO.open(rpm_spec)
end

When('developer loads the spec') do
   @space = Setup::Space::Spec.load_from(@spec_in)
end

When('property {string} of space is {string}') do |property, value|
   expect(@space.send(property)).to eql(value)
end

When('property {string} of space has {string}') do |property, value|
   real = @space.send(property)
   list = real.is_a?(Hash) && real.values || real
   expect(list).to include(value)
end

When('property {string} of space has {string} at position {string}') do |property, value, pos|
   # binding.pry
   list = @space.send(property)
   real = list.is_a?(Hash) && list[pos] || list[pos.to_i]
   expect(real).to eql(value)
end

When('property {string} of space has text:') do |property, text|
   list = @space.send(property)
   real = list.is_a?(Hash) && list.values || list
   expect(real).to include(text)
end

When('space\'s property {string} with argument {string} has text:') do |property, arg, text|
   expect(@space.send(property)[arg]).to eql(text)
end
