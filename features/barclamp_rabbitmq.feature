@rabbitmq
Feature: Test the AMQP Messaging service
  As an administrator
  I want to make sure the messaging service is deployed successfully

  Background:
    Given the chef role "rabbitmq-server" exists on admin node
    And the "rabbitmq" cookbook exists on the admin node

  Scenario: RabbitMQ Successful deployment
    Given the barclamp proposal is using rabbitmq as messaging backend
    When the node with rabbitmq-server role has been detected successfully
    Then I can check the status of rabbitmq-server using command line
    And I can add a new user and view the user in the users list
    And I can change the user's role to an adminstrator
    And I can delete the user and verify the users list
