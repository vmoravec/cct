Given(/^the environment variable "([^"]*)" is set$/) do |vm_count|
  ENV["cct_vm_number"] = "10" if ENV["cct_vm_number"].nil?
  expect(ENV[vm_count]).not_to be_nil
end

Given(/^the variable "([^"]*)" has value greater than zero$/) do |vm_count|
  @vm_count = ENV[vm_count].to_i
  expect(@vm_count).to be > 0
  # Let's expect there is some number of VMs already in place (e.g. testsetup leftovers),
  # they must be considered when setting the quotas for neutron and nova later
  @vm_reserve = ENV["cct_vm_reserve"] || 3
end

Given(/^necessary rules for "([^"]*)" security group on port "([^"]*)" are present$/) do |sec_group, port_number|
  rule_found = openstack.security_group.rule.list(sec_group).find do |rule|
    rule.port_range.match("#{port_number}:#{port_number}")
  end

  if !rule_found
    openstack.security_group.rule.create(
      sec_group,
      dst_port: port_number.to_i
    )
  end
end

Given(/^necessary rules for "([^"]*)" security group on "([^"]*)" protocol are present$/) do |sec_group, protocol|
  rule_found = openstack.security_group.rule.list(sec_group).find do |rule|
    rule.protocol == "icmp"
  end

  if !rule_found
    openstack.security_group.rule.create(
      sec_group,
      proto: "icmp"
    )
  end
end

Given(/^"([^"]*)" quotas for cores and instances in project "([^"]*)" have been updated$/) do |default, project|
  quota_class_update(
    "default",
    instances:    @vm_count + @vm_reserve,
    cores:        @vm_count + @vm_reserve,
    floating_ips: @vm_count + @vm_reserve
  )

  quota_class_update(
    project,
    instances:    @vm_count + @vm_reserve,
    cores:        @vm_count + @vm_reserve,
    floating_ips: @vm_count + @vm_reserve
  )
end

Given(/^respective quotas for nova in project "([^"]*)" have been updated$/) do |project|
  quota_update(
    :nova,
    floating_ips: @vm_count + @vm_reserve,
    instances:    @vm_count + @vm_reserve,
    tenant: project
  )
end

Given(/^respective quotas for neutron in project "([^"]*)" have been updated$/) do |project|
  quota_update(
    :neutron,
    port:   @vm_count + @vm_reserve,
    vip:    @vm_count + @vm_reserve,
    tenant: project
  )

  quota_update(
    :neutron,
    port:   @vm_count + @vm_reserve,
    vip:    @vm_count + @vm_reserve,
  )
end

Given(/^the image named "([^"]*)" is available$/) do |image_name|
  image = openstack.image.list.find {|i| i.name.match(/#{image_name}$/) }
  @image = openstack.image.show(image.name)
end

Given(/^the flavor "([^"]*)" is defined$/) do |flavor|
  @flavor = openstack.flavor.list.find {|f| f.name == flavor }
  @flavor = openstack.flavor.create(flavor) if @flavor.nil?
end

Given(/^the key pair "([^"]*)" has been created$/) do |keypair_name|
  @key_path = "/tmp/#{keypair_name}"
  control_node.exec!("rm -rf #@key_path*")
  control_node.exec!(
    "ssh-keygen -t dsa -f #{@key_path}  -N ''"
  )
  control_node.exec!(
    "chmod 600 #{@key_path}*"
  )

  if openstack.keypair.list.find {|k| k.name.match(keypair_name) }
    control_node.openstack.keypair.delete(keypair_name)
  end

  control_node.openstack.keypair.create(keypair_name, public_key: "#{@key_path}.pub")
  @keypair_name = keypair_name
end

Given(/^there are no VMs with the name "([^"]*)" present$/) do |vm_name|
  @vm_name = vm_name
  @wait = ENV["cct_wait_for_vm"].nil? ? true : (ENV["cct_wait_for_vm"].to_i.zero? ? false : true)
  delete_vms(name: @vm_name)
end

When(/^I request creating VMs with name "([^"]*)"$/) do |vm_name|

  options = {
    image:    @image.name,
    flavor:   @flavor.name,
    key_name: @keypair_name,
  }

  if @wait
    options.merge!(wait: true, max: @vm_count)
    openstack.server.create(vm_name, options)
  else
    1.upto(@vm_count).each do |num|
      openstack.server.create("#{vm_name}-#{num}", options)
    end
  end
end

Then(/^I get all the VMs listed as "([^"]*)"$/) do |status_active|
  @all_vms = []
  wait_for("VMs being up and running successfully", max: "#{@vm_count*5} seconds", sleep: "2 seconds") do
    @all_vms = openstack.server.list.select {|vm| vm.name.match(@vm_name)}
    statuses = @all_vms.map(&:status)
    active = statuses.select {|status| status == "ACTIVE"} || []
    break if active.count == @all_vms.count
  end
  expect(@all_vms.count).to eq(@vm_count)
end

Then(/^there are enough floating IPs available$/) do
  fip_limit = ENV["cct_fip_number"].to_i
  ips = openstack.ip_floating.list.select {|ip| ip.instance_id.empty? }

  if fip_limit.nonzero?
    needed = fip_limit > ips.size ? fip_limit - ips.size : fip_limit
  else
    needed =  @all_vms.size - ips.size
  end

  1.upto(needed).each do
    openstack.ip_floating.create("floating")
  end
  @floating_ips = openstack.ip_floating.list.select {|ip| ip.instance_id.empty? }
  @all_vms = @all_vms.sample(fip_limit) if fip_limit.nonzero?
end

When(/^I assign floating IPs to the VMs$/) do
  Ip = Struct.new(:id, :ip)
  @vm_ips = {}
  @all_vms.each_with_index do |vm, index|
    floating = @floating_ips[index]
    openstack.ip_floating.add(floating.ip, vm.id)
    @vm_ips[vm.id] = Ip.new(floating.id, floating.ip)
  end
end

Then(/^I can ping running VMs$/) do
  @all_vms.each {|vm| ping_vm(@vm_ips[vm.id].ip) }
end

Then(/^I ssh to VMs successfully as "([^"]*)" user$/) do |user|
  @all_vms.each do |vm|
    control_node.exec!("ssh #{user}@#{@vm_ips[vm.id].ip} -i #{@key_path} 'echo test'")
  end
end

Then(/^I remove the floating IPs from all VMs$/) do
  @all_vms.each do |vm|
    openstack.ip_floating.remove(@vm_ips[vm.id].ip, vm.id)
  end
end

Then(/^I delete floating IPs from the pool$/) do
  @all_vms.each do |vm|
    openstack.ip_floating.delete(@vm_ips[vm.id].id)
  end
end

Then(/^I delete all the VMs used for testing$/) do
  delete_vms(name: @vm_name)
end


