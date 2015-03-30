Feature: Admin node
  As a cloud administrator
  I want to validate the admin node installation and configuration
  In order to make sure the node management is all set

  Background:
    Given the admin node responds to a ping
    And I can establish SSH connection
    And I can reach the crowbar API

  @os
  Scenario: Operating system support
    Given the admin node is running "SUSE Linux Enterprise Server 11"
    Given I successfully detected attributes of the admin node system
    Then I want them to match our system expectations

  @ntp
  Scenario: NTP Server availability
    Given the NTP Server is running
    When I request server for estimated correct local date and time
    Then I receive a response within the "5" seconds timeout

  @services
  Scenario: Required services installed and running

