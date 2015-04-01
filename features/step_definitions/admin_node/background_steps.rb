Given(/^the admin node responds to a ping$/) do
  admin_node.ping!
  ping!(admin_node)
end

Given(/^I can establish SSH connection$/) do
  admin_node.test_ssh!
  ssh_handshake!(admin_node)
end

Given(/^I can reach the crowbar API$/) do
  admin_node.test_api!
  crowbar.test!
end
