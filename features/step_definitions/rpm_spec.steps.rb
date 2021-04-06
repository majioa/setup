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
   expect(@space.send(property)[""]).to eql(string)
end

Then('property {string} of space with no argument is:') do |property, text|
   expect(@space.send(property)[""]).to eql(text)
end

Then('property {string} of space has {string}') do |property, value|
   real = @space.send(property)
   list = real.is_a?(OpenStruct) && real.each_pair.to_a.transpose[1] || real
   expect(list).to include(value)
end

Then('property {string} of space has {string} at position {string}') do |property, value, pos|
   list = @space.send(property)
   real = list.is_a?(OpenStruct) && list[pos] || list[pos.to_i]
   expect(real).to eql(value)
end

Then('property {string} of space has text:') do |property, text|
   list = @space.send(property)
   real = list.is_a?(OpenStruct) && list.each_pair.to_a.transpose[1] || list
   expect(real).to include(text)
end

Then('space\'s property {string} with argument {string} has text:') do |property, arg, text|
   expect(@space.send(property)[arg]).to eql(text)
end

Then('space\'s property {string} with argument {string} has fields:') do |property, arg, table|
   h = @space.send(property)[arg]
   table.rows_hash.each { |key, value| expect(h[key]).to eql(value) }
end

Then('secondary spec with adopted name {string} has fields:') do |arg, table|
   sec = @space.secondaries.find {|sec| sec.adopted_name == arg }

   expect(sec).to_not be_nil
   table.rows_hash.each { |key, value| expect(sec[key]).to eql(value) }
end

Then('the subfield {string} with argument {string} of space\'s property {string} with argument {string} has data:') do |subprop, subarg, property, arg, text|
   list = @space.send(property)[arg]

   expect(list).to_not be_nil
   expect(list[subprop][subarg]).to eql(text)
end

Then('the subfield {string} with no argument of space\'s property {string} with argument {string} has data:') do |subprop, property, arg, text|
   list = @space.send(property)[arg]

   expect(list).to_not be_nil
   expect(list[subprop][""]).to eql(text)
end

Then('the subfield {string} with argument {string} of secondary spec with adopted name {string} has data:') do |subprop, subarg, arg, text|
   sec = @space.secondaries.find {|sec| sec.adopted_name == arg }

   expect(sec).to_not be_nil
   expect(sec[subprop][subarg]).to eql(text)
end

Then('the subfield {string} with no argument of secondary spec with adopted name {string} has data:') do |subprop, arg, text|
   sec = @space.secondaries.find {|sec| sec.adopted_name == arg }

   expect(sec).to_not be_nil
   expect(sec[subprop][""]).to eql(text)
end

Then('the subfield {string} of secondary spec with adopted name {string} has data:') do |subprop, arg, text|
   sec = @space.secondaries.find {|sec| sec.adopted_name == arg }

   expect(sec).to_not be_nil
   expect(sec[subprop]).to eql(text)
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

   ##binding.pry
   expect(list[pos.to_i]).to be_kind_of(OpenStruct)
   table.rows_hash.each { |key, value| expect(list[pos.to_i][key.to_sym]).to eql(value != "" && value || nil) }
end

Then('property {string} of space\'s spec is {string}') do |property, value|
   expect(@space.spec.send(property)).to eql(value)
end

Then('the subfield {string} at position {string} of space\'s property {string} with argument {string} has data:') do |subprop, pos, property, arg, text|
   list = @space.send(property)[arg]

   expect(list).to_not be_nil
   expect(list[subprop][pos.to_i]).to eql(text)
end

