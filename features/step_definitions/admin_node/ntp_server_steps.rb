Given(/^the NTP Server is running$/) do
  expect(admin_node.exec!("service ntp status").output).to match(/running/)
end

When(/^I request server for estimated correct local date and time$/) do
  @sntp_result = timeout(10) { exec!("/usr/sbin/sntp", "#{admin_node.ip}").output }
end

Then(/^I receive a non-empty response$/) do
  expect(@sntp_result.length.nonzero?).to be_truthy
end

