Given(/^the following packages are installed:$/) do |table|
  table.rows.each do |row|
    package_name = row.first
    rpm_details = admin_node.rpm_q(package_name)
    if package_name == "suse-cloud-release"
      expect(rpm_details.output).to match("#{package_name}-#{config["cloud"]["version"]}")
    end
  end
end
