Given(/^the admin node responds to a ping$/) do
  admin_node.ping!
end

Given(/^I can establish SSH connection$/) do
  admin_node.test_ssh!
end

Given(/^I can reach the crowbar API$/) do
  admin_node.test_api!
end
