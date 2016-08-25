Feature: Upgrade cloud via browser UI
  As a cloud administrator
  I want to upgrade deployed cloud
  In order to use the latest SLE, crowbar and openstack version

  Background:
    Given the admin node responds to a ping
    And I can establish SSH connection
    And I can reach the crowbar API
    And the admin node is in "ready" state

  @landing
  Scenario: Landing page
    Given I click the "Upgrade" link to trigger the upgrade process
    And the upgrade process is successfuly initialized
    When I trigger the preliminary checks by clicking on "Run checks"
    Then all checks show successful results
    And  I get the "Begin Upgrade" button enabled

