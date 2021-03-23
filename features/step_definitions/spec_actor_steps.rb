# vim:setl sw=3 sts=3 ts=3 et:
Given('default setup') do
   # load setup from a file
   @space = Setup::Space.load_from("features/fixtures/default.setup")
end

When('developer applies {string} actor to the setup') do |actor_name|
   actor = Setup::Actor.for(actor_name)
   @spec = actor.apply(@space)
end

Then('he acquires a present spec for the setup') do
   expect(@spec).to_not be_nil
end

When('developer draws the template:') do |doc_string|
   @spec = Setup::Actor.for('spec').apply(@space, doc_string)
end

Then('he gets the RPM spec') do |doc_string|
   expect(@spec).to eql(doc_string)
end

