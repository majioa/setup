# vim:setl sw=3 sts=3 ts=3 et:
Given('default setup') do
   # load setup from a file
   @space = Setup::Space.load_from(space_in: "features/fixtures/default.setup")
end

When(/(?:he|developer) applies "([^"]*)" actor to the setup/) do |actor_name|
   actor = Setup::Actor.for(actor_name, space)
   @spec = actor.apply_to(space)
end

Then('he acquires a present spec for the setup') do
   expect(@spec).to_not be_nil
end

When(/(?:developer|he) draws the template:/) do |text|
   @spec = Setup::Actor.for('spec', space).apply_to(space, text)
end

Then('he gets the RPM spec') do |doc_string|
   expect(@spec).to eql(doc_string)
end

Then('he gets blank RPM spec') do
   expect(@spec).to eql("")
end
