Feature: Openstack Clients Functional Tests
  As admins and developers
  We want to make sure the functional tests for openstack client libraries are succeeding

  @novaclient
  Scenario: Nova Client tests
    Given the test package "python-novaclient-test" is installed on the controller node
    And the package "python-novaclient" is installed on the controller node
    And the proper cirros test image has been created
    Then all the functional tests for the package "python-novaclient" pass

  @manilaclient
  Scenario: Manila Client tests
    Given the test package "python-manilaclient-test" is installed on the controller node
    And the package "python-manilaclient" is installed on the controller node
    And the authentication for the "python-manilaclient" is established
    Then all the functional tests for the package "python-manilaclient" pass

