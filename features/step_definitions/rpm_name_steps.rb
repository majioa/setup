Given('an full name:') do |text|
   name_list << text
end

When('developer applies to parse the names with Name class') do
   names.replace(name_list.map { |n | Setup::Spec::Rpm::Name.parse(n) })
end

Then('he get name parsed as:') do |table|
   attrs = table.raw.to_h
   attrs.each { |attr, value| expect(names.first.send(attr)).to eql(adopt_value(value)) }
end

When('the name has support name object:') do |table|
   attrs = table.raw.to_h
   names.first.support_name = Setup::Spec::Rpm::Name.new(prefix: attrs["prefix"],
                                                         suffix: adopt_value(attrs["suffix"]),
                                                         name: attrs["name"])
end

Then('the names are fully matched:') do
   names.combination(2).each { |(n1, n2)| expect(n1.match?(n2)).to be_truthy }
end

Then('the names are matched in part of {string}') do |attr|
   names.combination(2).each { |(n1, n2)| expect(n1.match_by?(attr, n2)).to be_truthy }
end

Then('the names are not matched in part of {string}') do |attr|
   names.combination(2).each { |(n1, n2)| expect(n1.match_by?(attr, n2)).to be_falsey }
end

Then('the names are fully not matched') do
   names.combination(2).each { |(n1, n2)| expect(n1.match?(n2)).to be_falsey }
end

Then('the name\'s full name is :') do |text|
   expect(names.first.fullname).to eql(text)
end
