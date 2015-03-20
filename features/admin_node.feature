Feature: Admin node
  As a cloud administrator
  I want to validate the admin node installation and configuration
  In order to make sure the node management works flawlessly

  @os
  Scenario: Check operating system support
    Given I successfully detected parameters of the admin node system
    Then I want them to match our system expectations

  @ntp
  Scenario: Test NTP Server availability

  @services
  Scenario: Detect required services

