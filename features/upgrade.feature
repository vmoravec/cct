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
    When I click the "Check" button to trigger preliminary checks
    Then all checks show successful results
    And  I get the "Begin Upgrade" button enabled

  @admin_backup
  Scenario: Admin server backup
    Given I click the "Begin Upgrade" button on the landing page
    And button for "Download Backup of Administration Server" is available and enabled
    And the "Next" button is disabled
    When I click the backup button
    Then I get the backup archive created
    And the "Next" button gets enabled
    And I click the "Next" button to move to next upgrade action

