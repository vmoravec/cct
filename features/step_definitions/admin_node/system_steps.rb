Given(/^I successfully detected attributes of the admin node system$/) do
  admin_node.detect!
end

Then(/^I want them to match our system expectations$/) do
  admin_node.validate!
end

Given(/^I fail now$/) do
  expect(admin_node.validate!).to be(true)
end

