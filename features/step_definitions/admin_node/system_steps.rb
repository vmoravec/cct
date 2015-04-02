Given(/^I successfully detected attributes of the admin node system$/) do
  expect(admin_node.rpm?("suse-cloud-release").success?).to eq(true)
end

Then(/^I want them to match our system expectations$/) do
  pending
end

Given(/^the admin node is running "([^"]*)"$/) do |os_name|
  expect(admin_node.read_file("/etc/SuSE-release").output).to match(os_name)
end

