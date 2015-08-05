Given(/^the following services are available on the admin node$/) do |table|
  @services_table = table
  table.rows.each do |row|
    service_name = row.first
    admin_node.exec!("which #{service_name}")
  end
end

Given(/these services are enabled and running on the admin node$/) do
  @services_table.rows.each do |row|
    service_name = row.first

    expect(admin_node.exec!(
      "systemctl is-enabled #{service_name}"
    ).output).to match("enabled")

    expect(admin_node.exec!(
      "systemctl status #{service_name}"
    ).output).to match("running")
  end
end

