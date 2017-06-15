Given(/^the admin node is available$/) do
  validate_admin!
end

Given(/^monasca node is available$/) do
  @monasca_node = nodes.find(node_alias: "monasca").first
  expect(@monasca_node).not_to eq(nil)
  admin_node.ping!(@monasca_node)
end

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


