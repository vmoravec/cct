Given(/^the package "([^"]*)" is installed$/) do |cli_rpm|
  control_node.rpm_q(cli_rpm)
end

When(/^"([^"]*)" command is available on controller node$/) do |monasca_command|
  control_node.exec!(monasca_command, "help")
end

When(/^openrc file is adapted for monasca$/) do
  OPENRC_MONASCA = "/root/.openrc-monasca"
  control_node.exec!("cp /root/.openrc #{OPENRC_MONASCA}")
  control_node.exec!("sed -i -e \"s,OS_PROJECT_NAME='openstack',OS_PROJECT_NAME='monasca',\" #{OPENRC_MONASCA}")
end


Then(/^all monasca subcommands containing list succeed$$/) do |table|
  # table is a Cucumber::Core::Ast::DataTable
  table.rows.each do |row|
    subcommand = row.first
    control_node.exec!("monasca #{subcommand}", source: OPENRC_MONASCA)
  end
end

