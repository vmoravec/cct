Given(/^I got the controller controller node discovered$/) do
  control_node.load!
end

Given(/^the controller node responds to a ping$/) do
  admin_node.exec!("ping localhost")
end

Given(/^I can establish SSH connection to the controller node$/) do
  control_node.test_ssh!
end

Given(/^the controller node is in "([^"]*)" state$/) do |ready|
  puts control_node.exec!("echo .openrc")
  expect(control_node.status).to eq(ready)
end
