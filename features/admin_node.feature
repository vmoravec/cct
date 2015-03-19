Feature: Admin node
  As a cloud administrator
  I want to validate the the admin node deployment
  In order to proceed with Openstack deployment

  @system
  Scenario: Check system support
    Given I successfully detected parameters of the admin node system
    Then I want them to match our system expectations

  @ntp
  Scenario: Test NTP Server availability

  @services
  Scenario: Detect required services

