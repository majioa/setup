# vim:setl sw=3 sts=3 ts=3 et:
Given('RPM spec file:') do |rpm_spec|
   @spec_in = StringIO.open(rpm_spec)
end

When('developer loads the spec') do
   @space = Setup::Space::Spec.load_from(@spec_in)
end

Then('property {string} of space is {string}') do |property, value|
   expect(@space.send(property)).to eql(value)
end

Then('property {string} of space with no argument is {string}') do |property, string|
   expect(@space.send(property)[nil]).to eql(string)
end

Then('property {string} of space has {string}') do |property, value|
   real = @space.send(property)
   list = real.is_a?(Hash) && real.values || real
   expect(list).to include(value)
end

Then('property {string} of space has {string} at position {string}') do |property, value, pos|
   # binding.pry
   list = @space.send(property)
   real = list.is_a?(Hash) && list[pos] || list[pos.to_i]
   expect(real).to eql(value)
end

Then('property {string} of space has text:') do |property, text|
   list = @space.send(property)
   real = list.is_a?(Hash) && list.values || list
   expect(real).to include(text)
end

Then('space\'s property {string} with argument {string} has text:') do |property, arg, text|
   expect(@space.send(property)[arg]).to eql(text)
end

Then('space\'s property {string} with argument {string} has fields:') do |property, arg, table|
   h = @space.send(property)[arg]
   table.rows_hash.each { |key, value| expect(h[key]).to eql(value) }
end

Then('the subfield {string} with argument {string} of space\'s property {string} with argument {string} has data:') do |subprop, subarg, property, arg, text|
   list = @space.send(property)[arg]

   expect(list).to_not be_nil
   expect(list[subprop][subarg]).to eql(text)
end

Then('the subfield {string} with no argument of space\'s property {string} with argument {string} has data:') do |subprop, property, arg, text|
   list = @space.send(property)[arg]

   expect(list).to_not be_nil
   expect(list[subprop][nil]).to eql(text)
end

Then('the subfield {string} of space\'s property {string} with argument {string} has data:') do |subprop, property, arg, text|
   list = @space.send(property)[arg]

   expect(list).to_not be_nil
   expect(list[subprop]).to eql(text)
end

Then('space\'s property {string} has data:') do |property, text|
   expect(@space.send(property)).to eql(text)
end

Then('space\'s property {string} at position {string} has fields:') do |property, pos, table|
   list = @space.send(property)
   expect(list).to be_kind_of(Array)

   expect(list[pos.to_i]).to be_kind_of(Hash)
   table.rows_hash.each { |key, value| expect(list[pos.to_i][key.to_sym]).to eql(value != "" && value || nil) }
end

