Given(/^the test package "([^"]*)" is installed on the controller node$/) do |test_package|
  control_node.rpm_q(test_package)
end

Given(/^the package "([^"]*)" is installed on the controller node$/) do |client_package|
  control_node.rpm_q(client_package)
end

When(/^the proper cirros test image has been created$/) do
  @test_image = control_node.openstack.image.create(
    "cirros-test-image-uec",
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
  control_node.exec!(
    "/var/lib/novaclient/tests/functional/setup.py testr",
    "OS_NOVACLIENT_EXEC_DIR" => "/usr/bin",
    "OS_TEST_PATH" => "novaclient/tests/functional"
  )
end

