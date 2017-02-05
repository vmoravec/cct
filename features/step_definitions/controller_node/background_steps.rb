Given(/^I got the admin node discovered$/) do
  validate_admin!
end

Given(/^I got the controller controller node discovered$/) do
  control_node.load!
end

Given(/^the controller node responds to a ping$/) do
  admin_node.ping!(control_node)
end

Given(/^I can establish SSH connection to the controller node$/) do
  control_node.test_ssh!
end

Given(/^the controller node is in "([^"]*)" state$/) do |ready|
  # before checking for "ready" state, make sure the controller is not
  # in an "unknown" state
  60.times do
    break unless control_node.status == "unknown"
    control_node.load!(force: true)
    sleep 5
  end
  expect(control_node.status).to eq(ready)
end
