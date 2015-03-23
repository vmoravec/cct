Given(/^the NTP Server is running$/) do
  puts admin_node.exec!('cat /etc/SuSE-release')
end

When(/^I request server for estimated correct local date and time$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^I receive a response within the "([^"]*)" seconds timeout$/) do |arg1|
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^the result is within "([^"]*)" second$/) do |arg1|
  pending # Write code here that turns the phrase above into concrete actions
end

