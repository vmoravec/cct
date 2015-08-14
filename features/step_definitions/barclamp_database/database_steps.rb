Given(/^the barclamp proposal is using "([^"]*)" as sql engine$/) do |sql_engine_name|
  json_response = JSON.parse(admin_node.exec!("crowbar database show default").output)
  expect(json_response["attributes"]["database"]["sql_engine"]).to eq(sql_engine_name)
end

When(/^the node with database role has been detected successfully$/) do
  json_response = JSON.parse(admin_node.exec!("crowbar database show default").output)
  @node_fqdn = json_response["deployment"]["database"]["elements"]["database-server"].first
  expect(@node_fqdn).not_to be_empty
end

Then(/^I can establish connection to "([^"]*)" database server$/) do |db_name|
  @db_name = db_name
  json_response = JSON.parse(admin_node.exec!("crowbar database show default").output)
  @password = json_response["attributes"]["database"]["db_maker_password"]
  @node = nodes.find(fqdn: @node_fqdn)
  case db_name
  when "postgresql"
    @node.exec!("PGPASSWORD=#{@password} psql -U db_maker -h #{@node.fqdn} postgres -c 'SELECT 1'")
  when "mysql"
    @node.exec!("mysql -u db_maker --password=#{@password}  -h #{@node.fqdn} -e 'SELECT 1'")
  end
end

Then(/^I can create a database called "([^"]*)"$/) do |db|
  case @db_name
  when "postgresql"
    @node.exec!("PGPASSWORD=#{@password} psql -U db_maker -h #{@node.fqdn} postgres -c 'CREATE DATABASE #{db}'")
  when "mysql"
    @node.exec!("mysql -u db_maker --password=#{@password}  -h #{@node.fqdn} -e 'CREATE DATABASE #{db}'")
  end
end

Then(/^I can drop the database "([^"]*)" successfully$/) do |db|
  case @db_name
  when "postgresql"
    @node.exec!("PGPASSWORD=#{@password} psql -U db_maker -h #{@node.fqdn} postgres -c 'DROP DATABASE #{db}'")
  when "mysql"
    @node.exec!("mysql -u db_maker --password=#{@password}  -h #{@node.fqdn} -e 'DROP DATABASE #{db}'")
  end
end
