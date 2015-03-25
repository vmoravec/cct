Given(/^the admin node responds to a ping$/) do
  admin_node.ping!
end

Given(/^I can establish SSH connection$/) do
  admin_node.ssh_test!
end

Given(/^I can reach the crowbar API$/) do
  admin_node.api_test!
end
