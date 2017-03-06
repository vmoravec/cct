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

  @admin_repos
  Scenario: Admin repo checks
    Given I am on the page for admin repo checks for upgrade workflow
    And the "Check" button is available and enabled
    And the "Next" button is available and disabled
    When I click the "Check" button to verify new cloud repos on admin node
    Then I get successful results for all repos
    And I click the "Next" button to move to next upgrade action

  @admin_upgrade
  Scenario: Admin server upgrade
    Given I am on the page for upgrade admin server
    And button for "Upgrade Administration Server" is available and enabled
    And the "Next" button is disabled

  @pgsql_create
  Scenario: Create postgresql database
    Given I am on the page for creating postgresql database
    And the "Create Database" button is available and disabled
    And the "Next" button is available and disabled
    When I insert "crowbar" as the "username"
    And I insert "crowbar" as the "password"
    Then I click the "Create Database" button to set up the db backend
    And the "Create Database" button is disabled
    And I wait max "5 minutes" until the database is created
    And the "Next" button is available and enabled
    And I click the "Next" button to move to next upgrade action

  @nodes_repos
  Scenario: Nodes repo checks
    Given I am on the page for checking nodes repos
    And the "Check" button is available and enabled
    And the "Next" button is available and disabled
    When I click the "Check" button to verify new cloud repos on for all nodes
    Then I get successful results for all repos
    And I click the "Next" button to move to next upgrade action
