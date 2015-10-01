Given(/^the barclamp proposal is using "([^"]*)" as sql engine$/) do |sql_engine_name|
  @db_proposal = proposal("database")
  expect(@db_proposal["attributes"]["database"]["sql_engine"]).to eq(sql_engine_name)
end

When(/^the node with database role has been detected successfully$/) do
  @db_nodes = nodes.find(barclamp: "database", element: "database-server")
  expect(@db_nodes).not_to be_empty
end

Then(/^I can establish connection to "([^"]*)" database server$/) do |db_name|
  @db_name = db_name
  @password = @db_proposal["attributes"]["database"]["db_maker_password"]
  results = @db_nodes.map do |node|
    case db_name
    when "postgresql"
      node.exec!(
        "PGPASSWORD=#{@password} psql -U db_maker -h #{node.fqdn} postgres -c 'SELECT 1'",
        capture_error: true
      )
    end
  end
  expect(results).to succeed_at_least_once
end

Then(/^I can create a database called "([^"]*)"$/) do |db|
  results = @db_nodes.map do |node|
    case @db_name
    when "postgresql"
      node.exec!("PGPASSWORD=#{@password} psql -U db_maker -h #{node.fqdn} postgres -c 'CREATE DATABASE #{db}'")
    end
  end
  expect(results).to succeed_at_least_once
end

Then(/^I can drop the database "([^"]*)" successfully$/) do |db|
  results = @db_nodes.map do |node|
    case @db_name
    when "postgresql"
      node.exec!("PGPASSWORD=#{@password} psql -U db_maker -h #{node.fqdn} postgres -c 'DROP DATABASE #{db}'")
    end
  end
  expect(results).to succeed_at_least_once
end
