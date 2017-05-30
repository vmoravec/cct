Given(/^the test package "([^"]*)" is installed on the controller node$/) do |test_package|
  control_node.rpm_q(test_package)
end

Given(/^the package "([^"]*)" is installed on the controller node$/) do |client_package|
  control_node.rpm_q(client_package)
end

Given(/^the proper cirros test image has been created$/) do
  test_image_name = "cirros-test-image-uec"

  if control_node.openstack.image.list.find {|img| img.name == test_image_name }
    control_node.openstack.image.delete(test_image_name)
  end

  imagedir = File.expand_path "~/cct-images/"
  imagesource = "http://clouddata.nue.suse.com/images/cirros-0.3.4-x86_64-disk.img"
  control_node.download_file imagesource, imagedir, test_image_name
  @test_image = control_node.openstack.image.create(
    test_image_name,
    file: "/#{imagedir}/#{test_image_name}",
    container_format: :bare,
    disk_format: :qcow2,
    public: true
  )
  control_node.rmdir imagedir

  wait_for "Image status set 'active'", max: "60 seconds", sleep: "2 seconds" do
    image = control_node.openstack.image.show(@test_image.id)
    break if image.status == "active"
  end
end

And(/^the authentication for the "([^"]*)" is established$/) do |package_name|
  openrc = control_node.get_hash_from_envfile
  json_manila = proposal("manila")
  json_keystone = proposal("keystone")

  auth_hash = {
    username: json_manila["attributes"]["manila"]["service_user"],
    password: json_manila["attributes"]["manila"]["service_password"],
    tenant_name: "service",
    auth_url: openrc["OS_AUTH_URL"],
    admin_username: json_keystone["attributes"]["keystone"]["admin"]["username"],
    admin_password: json_keystone["attributes"]["keystone"]["admin"]["password"],
    admin_tenant_name: json_keystone["attributes"]["keystone"]["admin"]["tenant"],
    insecure: json_keystone["attributes"]["keystone"]["ssl"]["insecure"] ||
      json_manila["attributes"]["manila"]["ssl"]["insecure"],
    admin_auth_url: openrc["OS_AUTH_URL"],
    share_type: "default",
    suppress_errors_in_cleanup: true
  }
  service_name = package_name.match(/python-(.+)/).captures.first
  conf_file = "/etc/#{service_name}/#{service_name}.conf"
  auth_hash.each do |key, value|
    control_node.exec!("crudini", "--set #{conf_file} DEFAULT #{key} #{value}")
  end
end

Then(/^all the functional tests for the package "([^"]*)" pass$/) do |package_name|
  tests_dir = "/var/lib/#{package_name}-test"
  package_core_name = package_name.match(/python-(.+)/).captures.first

  json_keystone = proposal("keystone")
  ssl_insecure = json_keystone["attributes"]["keystone"]["ssl"]["insecure"]

  case package_name
  when "python-novaclient"
    json_response = proposal("nova")
    ssl_insecure ||= json_response["attributes"]["nova"]["ssl"]["insecure"]
    env = {
      OS_USER_DOMAIN_ID: "default",
      OS_PROJECT_DOMAIN_ID: "default",
      OS_NOVACLIENT_EXEC_DIR: "/usr/bin",
      OS_NOVACLIENT_NETWORK: "fixed"
    }
  when "python-manilaclient"
    json_response = proposal("manila")
    ssl_insecure ||= json_response["attributes"]["manila"]["ssl"]["insecure"]
    env = {
      OS_MANILA_EXEC_DIR: "/usr/bin",
      OS_MANILACLIENT_CONFIG_FILE: "/etc/manilaclient/manilaclient.conf",
      OS_MANILACLIENT_CONFIG_DIR: "/etc/manilaclient/",
      OS_ENDPOINT_TYPE: "internalURL"
    }
  end
  env["OS_TEST_PATH"] = "#{package_core_name}/tests/functional"
  env["OS_INSECURE"] = "true" if ssl_insecure
  tests_to_run = "tests_to_run"
  excluded_tests =
    case package_name
    when "python-novaclient"
      [
        "test_servers",             # non-external
        "test_auth"                 # need to be investigated
      ]
    when "python-manilaclient"
      [
        "test_create_delete_share_type",                   # uses DHSS True (currently not default)
        "test_list_with_debug_flag",                       # Similar to test_lists except for debug flag
        "test_scheduler_stats",                            # Requires a backend named "mybackend"
        "test_quotas",                                     # uses assertRaises but command does not fail. Needs correction upstream.
        "test_share_server_list_by_user",                  # crowbar doesnt create share-servers
        "test_add_remove_access_to_private_share_type",    # needs keystone v3 support
        "test_shares_list_filter_by_share_server_as_user", # needs keystone v3 support
        "test_shares_list_filter_by_project_id",           # needs keystone v3 support
        "test_list_shares_by_project_id"                   # needs keystone v3 support
        # Bug report: https://bugs.launchpad.net/python-manilaclient/+bug/1516562
      ]
    end

  if excluded_tests.any?
    # filter out the excluded tests into a file first
    control_node.exec!(
      "cd #{tests_dir};
        testr list-tests | grep -v '#{excluded_tests.join('\|')}\' > #{tests_to_run}",
      env
    )
    # run the tests finally
    control_node.exec!(
      "cd #{tests_dir}; python setup.py testr --testr-args '--load-list #{tests_to_run}'",
      env
    )
  else
    # run the tests finally
    control_node.exec!(
      "cd #{tests_dir}; python setup.py testr", env)
  end
end
