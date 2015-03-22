Feature: Admin node
  As a cloud administrator
  I want to validate the admin node installation and configuration
  In order to make sure the node management is all set

  @os
  Scenario: Check operating system support
    Given the admin node is running "SLE11-SP3" system 
    Given I successfully detected attributes of the admin node system
    Then I want them to match our system expectations

  @ntp
  Scenario: Test NTP Server availability
    Given I fail now

  @services
  Scenario: Detect required services

