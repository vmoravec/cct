Feature: Test the database server resource
  As an administrator
  I want to make sure the database service is deployed successfully
  In order to be available for other services later

  Background:
    Given the chef role "database-server" exists on admin node
    And the "database" cookbook exists on the admin node

  @postgresql
  Scenario: Database barclamp is deployed using PostgreSQL as backend
    Given the "postgresql" cookbook exists on the admin node
    And the barclamp proposal is using "postgresql" as sql engine
    When the node with database role has been detected successfully
    And the service "postgresql.service" is enabled and running on the detected node
    Then I can establish connection to "postgresql" database server
    And I can create a database called "cucumber_test"
    And I can drop the database "cucumber_test" successfully
