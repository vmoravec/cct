Given(/^the image "([^"]*)" is available$/) do |image_name|
  @image = control_node.openstack.image.show(image_name)
end

Given(/^network with name "([^"]*)" exists$/) do |network_name|
  network = control_node.openstack.network.list.find {|n| n == network_name}
  if network.nil?
    control_node.openstack.network.create(network_name)
  end
  @network = control_node.openstack.network.show(network_name)
  log.info(@network.inspect)
end

Given(/^flavor "([^"]*)" exists$/) do |flavor_name|
  @flavor = control_node.openstack.flavor.show(flavor_name)
  log.info(@flavor.inspect)
end

When(/^I create a new virtual machine "([^"]*)"$/) do |vm_name|
  @vm_name = vm_name
  control_node.openstack.server.create(vm_name, key: @key, image: @image, flavor: @flavor)
end

When(/^the VM has started successfully$/) do
  status = control_node.openstack.server.show(vm_name).status
  expect(status).to eq("ACTIVE")
end

When(/^I create a new volume with type "([^"]*)" size "([^"]*)"GB$/) do |arg1, arg2|
  pending # Write code here that turns the phrase above into concrete actions
end

When(/^the volume was successfully created$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^I attach the volume to the server created before$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^the volume is added to the server successfully$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

