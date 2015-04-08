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
      "chkconfig #{service_name}"
    ).output).not_to match("unknown service")

    expect(admin_node.exec!(
      "service #{service_name} status"
    ).output).to match("running")
  end
end

