Given(/^I got the admin node discovered$/) do
  validate_admin!
end

Given(/^I got the controller controller node discovered$/) do
  control_node.load!
end

Given(/^the controller node responds to a ping$/) do
  admin_node.exec!("ping", "-q -c 1 -W 5 #{control_node.ip}")
end

Given(/^I can establish SSH connection to the controller node$/) do
  control_node.test_ssh!
end

Given(/^the controller node is in "([^"]*)" state$/) do |ready|
  expect(control_node.status).to eq(ready)
end
