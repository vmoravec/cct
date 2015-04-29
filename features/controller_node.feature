@controller
Feature: Controller node
  As an administrator
  I want to make sure the controller node is configured and running
  In order to control other Openstack components

  Background:
    Given I can reach the crowbar API
    And I got the admin node discovered
    And I got the controller controller node discovered
    And the controller node responds to a ping
    And I can establish SSH connection to the controller node
    And the controller node is in "ready" state

  @system
  Scenario: Essential system requirements

