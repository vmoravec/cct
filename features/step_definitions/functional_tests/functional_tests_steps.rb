Given(/^the test package "([^"]*)" is installed on the controller node$/) do |test_package|
  control_node.rpm_q(test_package)
end

Given(/^the package "([^"]*)" is installed on the controller node$/) do |client_package|
  @client_rpm = client_package
  control_node.rpm_q(client_package)
end

Then(/^all the tests for the package have been executed successfully$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

