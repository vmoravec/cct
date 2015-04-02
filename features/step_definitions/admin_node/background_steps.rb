Given(/^the admin node responds to a ping$/) do
  ping!(admin_node)
end

Given(/^I can establish SSH connection$/) do
  admin_node.test_ssh!
end

Given(/^I can reach the crowbar API$/) do
  crowbar.test!
end
