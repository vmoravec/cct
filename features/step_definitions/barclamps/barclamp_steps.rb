Given(/^the chef role "([^"]*)" exists on admin node$/) do |role_name|
  admin_node.exec!("knife role show #{role_name}")
end

Given(/^the "([^"]*)" cookbook exists on the admin node$/) do |cookbook_name|
  admin_node.exec!("knife cookbook show #{cookbook_name}")
end
