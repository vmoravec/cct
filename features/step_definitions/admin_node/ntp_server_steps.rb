Given(/^the NTP Server is running$/) do
  expect(admin_node.exec!('service ntp status')).to match(/running/)
end

When(/^I request server for estimated correct local date and time$/) do
  expect(`sntp #{admin_node.ip}`).to match(/Started sntp/)
end

Then(/^I receive a response within the "([^"]*)" seconds timeout$/) do |to_seconds|
  timeout(to_seconds.to_i) { `sntp #{admin_node.ip}`}
end

Then(/^the correction is within "([^"]*)" second$/) do |correction|
  sntp_result = `sntp #{admin_node.ip}`
  actual_correction = sntp_result.split("+/-").last.split.first.to_f
  expect(actual_correction).to be < correction.to_f
end

