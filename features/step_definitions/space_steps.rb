# vim:setl sw=3 sts=3 ts=3 et:
Given('space file:') do |doc_string|
   @space_in = StringIO.open(doc_string)
end

When('developer loads the space') do
   @space = Setup::Space.load_from(@space_in)
end

Then('he sees that space\'s {string} is a {string}') do |prop, value|
   expect(@space.send(prop)).to eql(value)
end

When('developer locks the time to {string}') do |time|
   Timecop.freeze(Time.parse(time))
end
