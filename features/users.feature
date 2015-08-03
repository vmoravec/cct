@users
Feature: OpenStack Identity
  As an administrator
  I want to make sure the Keystone component is configured and running
  In order to provide authentification and authorization service to other Openstack components

  Background:
    Given project 'openstack' exists
    And the test user does not exist
    And I create the test user
    And I enable the user

  @enable_user
  Scenario: Enabled user
    Then Nova accepts this user

  @disable_user
  Scenario: Disabled user
    When I disable the user
    Then Nova does not accept this user

  @reenable_user
  Scenario: Reenable user
    When I disable the user
    And I enable the user
    Then Nova accepts this user

  @delete_user
  Scenario: Delete user
    When I delete this user
    Then Nova does not accept this user
