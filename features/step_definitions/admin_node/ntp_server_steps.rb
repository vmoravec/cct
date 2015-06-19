Given(/^the NTP Server is running$/) do
  expect(admin_node.exec!("service ntp status").output).to match(/running/)
end

When(/^I request server for estimated correct local date and time$/) do
  expect(exec!("/usr/sbin/sntp", "#{admin_node.ip}").output).to match(/\d{4}\s{1}\w+\s{1}\d{2}\s{1}/)
end

Then(/^I receive a response within the "([^"]*)" seconds timeout$/) do |to_seconds|
  timeout(to_seconds.to_f) { exec!("/usr/sbin/sntp", "#{admin_node.ip}") }
end

