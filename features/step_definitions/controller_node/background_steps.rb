Given(/^I got the controller controller node discovered$/) do
  # It's enough just to call the method, it fails by default if the
  # request for controller node data was not successful
  control_node
end

Given(/^the controller node responds to a ping$/) do
  ping!(control_node)
end

Given(/^I can establish SSH connection to the controller node$/) do
  ssh_handshake!(control_node)
end

Given(/^the controller node is in "([^"]*)" state$/) do |ready|
  control_node.crowbar.status == ready
end
