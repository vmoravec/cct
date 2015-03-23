Given(/^I successfully detected attributes of the admin node system$/) do
end

Then(/^I want them to match our system expectations$/) do
  admin_node.validate!
end

