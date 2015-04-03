Given(/^the admin node is running "([^"]*)"$/) do |os_name|
  release_file = admin_node.read_file("/etc/SuSE-release")
  admin_config = config["admin_node"]["os"]
  expect(release_file).to match(os_name)
  expect(release_file).to match("VERSION = #{admin_config["version"]}")
  expect(release_file).to match(
    "PATCHLEVEL = #{admin_config["patchlevel"]}"
  )
end

