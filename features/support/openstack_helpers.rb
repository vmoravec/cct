module OpenstackHelpers

  def ping_vm ip
    control_node.exec!("ping", "-q -c 2 -w 3 #{ip}")
  end

  def delete_vms name: nil, wait: true, all: false, ids: []
    options = wait ? {wait: true} : {}

    if !ids.empty?
      openstack.server.delete(ids, options)
      return
    end

    if all
      openstack.server.list.each {|s| openstack.server.delete(s.id, options) }
      return
    end

    vms = openstack.server.list
    ids = vms.select {|vm| vm.name.match(/#{name}/)}.map(&:id)
    openstack.server.delete(ids, options) unless ids.empty?
  end

  def openstack
    control_node.openstack
  end

  def quota_update component, options={}
    case component
    when :nova    then nova_quota_update(options)
    when :neutron then neutron_quota_update(options)
    end
  end

  def quota_class_update classname, options
    command = "nova --insecure quota-class-update "
    command << "--instances #{options[:instances]} "   if options[:instances]
    command << "--cores #{options[:cores]} "           if options[:cores]
    command << "--floating #{options[:floating_ips]} " if options[:floating_ips]
    command << classname
    control_node.exec!(command)
  end

  private

  def nova_quota_update options
    command = "nova --insecure quota-update "
    command << "--floating-ips #{options[:floating_ips]} "
    command << "--instances #{options[:instances]} "
    command << options[:tenant]
    control_node.exec!(command)
  end

  def neutron_quota_update options
    command = "neutron --insecure quota-update "
    command << "--port #{options[:port]} "
    command << "--vip #{options[:vip]} "
    command << "--tenant-id #{options[:tenant]}" if options[:tenant]
    control_node.exec!(command)
  end

end

