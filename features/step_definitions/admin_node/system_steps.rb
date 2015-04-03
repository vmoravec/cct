Given(/^the following packages are installed:$/) do |table|
  table.rows.each do |row|
    package_name = row.first
    rpm_details = admin_node.rpm_q(package_name)
    if package_name == "suse-cloud-release"
      expect(rpm_details.output).to match("#{package_name}-#{config["cloud"]["version"]}")
    end
  end
end

Then(/^I verify the admin node is in "([^"]*)" state$/) do |state|
  admin_node.crowbar.status == state.to_s
end

Given(/^the admin node is running "([^"]*)"$/) do |os_name|
  release_file = admin_node.read_file("/etc/SuSE-release")
  admin_config = config["admin_node"]["os"]
  expect(release_file).to match(os_name)
  expect(release_file).to match("VERSION = #{admin_config["version"]}")
  expect(release_file).to match(
    "PATCHLEVEL = #{admin_config["patchlevel"]}"
  )
end

