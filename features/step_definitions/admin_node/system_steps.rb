Given(/^I successfully detected parameters of the admin node system$/) do
  admin_node.detect!
end

Then(/^I want them to match our system expectations$/) do
  admin_node.validate!
end

