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

  @test_image = control_node.openstack.image.create(
    test_image_name,
    copy_from: "http://clouddata.cloud.suse.de/images/cirros-0.3.3-x86_64-uec.tar.gz",
    container_format: :bare,
    disk_format: :raw,
    public: true
  )
end

When(/^the cirros test image has been activated$/) do
  wait_for "Image status set 'active'", max: "60 seconds", sleep: "2 seconds" do
    image = control_node.openstack.image.show(@test_image.id)
    break if image.status == "active"
  end
end

Then(/^all the funtional tests for the package pass$/) do
  tests_dir = "/var/lib/python-novaclient-test"
  env = {
    "OS_NOVACLIENT_EXEC_DIR" => "/usr/bin",
    "OS_TEST_PATH" => "novaclient/tests/functional"
  }
  tests_list = "tests_to_run"
  excluded_tests = [
    "test_admin_dns_domains" # Does not work with neutron which means always for us
  ]

  # filter out the excluded tests into a file first
  control_node.exec!(
    "cd #{tests_dir};
    testr list-tests | grep -v \"#{excluded_tests.join("\|")}\" > #{tests_list}",
    env
  )

  # run the tests finally
  control_node.exec!(
    "cd #{tests_dir}; python setup.py testr --testr-args \"--load-list #{tests_list}\"",
    env
  )
end

