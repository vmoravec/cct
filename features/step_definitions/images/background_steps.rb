Given(/^glance image does not exist$/) do

  # fill the scenario specific data
  with_scenario_config {|c|
    @image_name         = c["image_name"]
    @image_source       = c["image_source"]
    @properties         = c["properties"]
  }

  images = control_node.openstack.image.list.map { |i| i.name}

  if images.include? @image_name
    # delete existing image
    control_node.openstack.image.delete @image_name
  end
end
