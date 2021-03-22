# vim:set sw=3 sts=3 ts=3 et:
Given('default setup') do
   # load setup from a file
   @setup = Setup::Space.load_from("features/fixtures/default.setup")
end

When('developer applies {string} actor to the setup') do |actor_name|
   actor = Setup::Actor.for(actor_name)
   @spec = actor.apply(@setup)
end

Then('he acquires a present spec for the setup') do
   expect(@spec).to_not be_nil
end
