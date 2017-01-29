@admin
Feature: Admin node
  As a cloud administrator
  I want to validate the admin node environment
  In order to make sure the node management is working properly

  Background:
    Given the admin node responds to a ping
    And I can establish SSH connection
    And I can reach the crowbar API
    And the admin node is in "ready" state

# FIXME: enable this scenario again once we switch to SP2 admin node
#  @os
#  Scenario: Operating system support
#    Given the admin node is running correct SLES version

  @ntp
  Scenario: NTP Server availability
    Given the NTP Server is running
    When I request server for estimated correct local date and time
    Then I receive a non-empty response

  @packages
  Scenario: Essential packages installed
    Given the following packages are installed:
      | Package name:                        |
      | crowbar                              |
      | crowbar-core                         |
      | crowbar-openstack                    |
      | crowbar-ceph                         |
      | crowbar-ha                           |
      | crowbar-init                         |
      | crowbar-ui                           |
      | yast2-crowbar                        |
    And all dependencies of installed packages are satisfied

  @services
  Scenario: Essential services enabled and active
    Given the following services are available on the admin node
      | Service name                         |
      | chef-server                          |
      | crowbar                              |
      | rabbitmq-server                      |
    And these services are enabled and running on the admin node
