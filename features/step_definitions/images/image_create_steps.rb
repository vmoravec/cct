Given(/^source image of kvm type exists$/) do
  my_config     = config["features"]["images"]["kvm"]
  @image_name   = my_config["image_name"]
  @image_source = my_config["image_source"]
  @properties   = my_config["properties"]
  control_node.remote_file_exists @image_source
end

Given(/^source image of xen_hvm type exists$/) do
  my_config     = config["features"]["images"]["xen_hvm"]
  @image_name   = my_config["image_name"]
  @image_source = my_config["image_source"]
  @properties   = my_config["properties"]
  control_node.remote_file_exists @image_source
end

Given(/^source image of xen_pv type exists$/) do
  my_config     = config["features"]["images"]["xen_pv"]
  @image_name   = my_config["image_name"]
  @image_source = my_config["image_source"]
  @properties   = my_config["properties"]
  control_node.remote_file_exists @image_source
end

Given(/^glance image does not exist$/) do
  images = control_node.openstack.image.list.map { |i| i.name}
  if images.include? @image_name
    control_node.openstack.image.delete @image_name
  end
end

When(/^I create new glance image based on jeos$/) do
  control_node.openstack.image.create @image_name,
    :properties => @properties,
    :disk_format => "qcow2",
    :public => true,
    :container_format => "bare",
    :copy_from => @image_source
end

Then(/^this image has non-empty ID$/) do
  images = control_node.openstack.image.list
  images.each do |i|
    @image_id   = i.id if i.name == @image_name
  end
  expect(@image_id).not_to be_empty
end

Then(/^its ID can be used to show the image info$/) do
  control_node.openstack.image.show(@image_id)
end

Then(/^the status of the image is active$/) do
  # it may take some time before the image turns active
  wait_for "Checking that image status is active", max: "120 seconds", sleep: "2 seconds" do
    show = control_node.openstack.image.show(@image_id)
    break if show.status == "active"
  end
end

Then(/^the image can be deleted$/) do
  steps %{
    When I delete the image
    Then it is no longer listed
  }
end

When(/^I delete the image$/) do
  control_node.openstack.image.delete @image_id
end

Then(/^it is no longer listed$/) do
  images = control_node.openstack.image.list.map { |i| i.name}
  expect(images).not_to include @image_name
end
