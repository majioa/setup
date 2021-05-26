# vim:setl sw=3 sts=3 ts=3 et:
Given('a spec from fixture {string}') do |name|
   @spec_in = IO.read("features/fixtures/#{name}/original.spec")
end

When(/(?:developer|he) sets the space option "rootdir" to fixture "([^"]*)"/) do |name|
   space.options["rootdir"] = "features/fixtures/#{name}"
end

Then('he acquires an {string} fixture spec for the setup') do |name|
   expect(@spec).to eql(IO.read("features/fixtures/#{name}/gem.spec").strip)
end

When('he sets the space options as:') do |table|
   # table is a Cucumber::MultilineArgument::DataTable
   table.raw[1..-1].to_h.each {|name, value| space.options[name] = adopt_value(value) }
end
