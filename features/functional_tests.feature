Feature: Openstack Clients Functional Tests
  As admins and developers
  We want to make sure the functional tests for openstack client libraries are succeeding

  @novaclient
  Scenario: Nova Client tests
    Given the test package "python-novaclient-test" is installed on the controller node
    And the package "python-novaclient" is installed on the controller node
    When the proper cirros image has been detected
    And the image has been cloned with name "cirros-test-image-uec"
    Then all the tests for the package have been executed successfully

