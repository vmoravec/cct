Feature: Openstack Clients Functional Tests
  As admins and developers
  We want to make sure the functional tests for openstack client libraries are succeeding

  @novaclient
  Scenario: Nova Client tests
    Given the test package "python-novaclient-test" is installed on the controller node
    And the package "python-novaclient" is installed on the controller node
    And the proper cirros test image has been created
    Then all the funtional tests for the package "python-novaclient" pass

