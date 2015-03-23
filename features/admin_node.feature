Feature: Admin node
  As a cloud administrator
  I want to validate the admin node installation and configuration
  In order to make sure the node management is all set

  @smoke
  Scenario: Smoke test

  @os
  Scenario: Operating system support
    Given the admin node is running "SLE11-SP3" system 
    Given I successfully detected attributes of the admin node system
    Then I want them to match our system expectations

  @ntp
  Scenario: NTP Server availability
    Given the NTP Server is running
    When I request server for estimated correct local date and time
    Then I receive a response within the "10" seconds timeout
    And the result is within "1" second

  @services
  Scenario: Required services detected

