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
