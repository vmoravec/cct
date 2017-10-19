Feature: Example of a test
  As a cloud user
  I want to perform various validations
  In order to verify the feature functionality

  Scenario: Run test example
    Given the image "cirros-0.3.5-x86_64-tempest-machine" is available
    And network with name "vmoravec-net" exists
    When I create a new virtual machine "vmoravec-vm"
    And the VM has started successfully
    When I create a new volume with type "vmoravec-vol1" size "3"GB
    And the volume was successfully created
    Then I attach the volume to the server created before
    And the volume is added to the server successfully

