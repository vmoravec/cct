Given(/^the admin node is running correct SLES version$/) do
  release_file = admin_node.read_file("/etc/os-release")
  admin_config = config["admin_node"]["os"]
  expect(release_file).to match(admin_config["name"])
  expect(release_file).to match("VERSION=\"#{admin_config["version"]}\"")
end


