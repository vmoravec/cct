Given(/^the barclamp proposal is using "([^"]*)" as sql engine$/) do |sql_engine_name|
  json_response = JSON.parse(admin_node.exec!("crowbar database show default").output)
  expect(json_response["attributes"]["database"]["sql_engine"]).to eq(sql_engine_name)
end

When(/^the node with database role has been detected successfully$/) do
  json_response = JSON.parse(admin_node.exec!("crowbar database show default").output)
  @db_nodes = json_response["deployment"]["database"]["elements"]["database-server"]
  expect(@db_nodes).not_to be_empty
end

Then(/^I can establish connection to "([^"]*)" database server$/) do |db_name|
  @db_name = db_name
  json_response = JSON.parse(admin_node.exec!("crowbar database show default").output)
  @password = json_response["attributes"]["database"]["db_maker_password"]
  @db_nodes.each do |node_name|
    node = nodes.find(fqdn: node_name)
    case db_name
    when "postgresql"
      node.exec!("PGPASSWORD=#{@password} psql -U db_maker -h #{node.fqdn} postgres -c 'SELECT 1'")
    end
  end
end

Then(/^I can create a database called "([^"]*)"$/) do |db|
  @db_nodes.each do |node_name|
    node = nodes.find(fqdn: node_name)
    case @db_name
    when "postgresql"
      node.exec!("PGPASSWORD=#{@password} psql -U db_maker -h #{node.fqdn} postgres -c 'CREATE DATABASE #{db}'")
    end
  end
end

Then(/^I can drop the database "([^"]*)" successfully$/) do |db|
  @db_nodes.each do |node_name|
    node = nodes.find(fqdn: node_name)
    case @db_name
    when "postgresql"
      node.exec!("PGPASSWORD=#{@password} psql -U db_maker -h #{node.fqdn} postgres -c 'DROP DATABASE #{db}'")
    end
  end
end

When(/^the service "([^"]*)" is enabled and running on the detected node$/) do |service_name|
  @db_nodes.each do |node_name|
    node = nodes.find(fqdn: node_name)
    node.exec!("systemctl is-enabled #{service_name}")
    node.exec!("systemctl is-active #{service_name}")
  end
end

