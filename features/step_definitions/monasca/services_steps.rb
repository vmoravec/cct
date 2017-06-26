Given(/^all monitoring services are enabled and running on the monasca node$/) do |table|
  # table is a Cucumber::Core::Ast::DataTable
  table.rows.each do |row|
    service_name = row.first
    result = @monasca_node.exec!("systemctl is-enabled #{service_name}")
    expect(result.output).to match("enabled")

    result = @monasca_node.exec!("systemctl is-active #{service_name}")
    expect(result.output).to match("active")
  end
end
