@images
Feature: OpenStack Image management
  As an administrator
  I want to make sure that OpenStack Image management component is working correctly

  Scenario Outline: Creating and deleting an image
    Given source image of <type> type exists
    And glance image does not exist
    When I create new glance image based on jeos
    Then this image has non-empty ID
    And its ID can be used to show the image info
    And the status of the image is active
    And the image can be deleted


  Examples:
    | type |
    | kvm  |
    | xen_hvm |
    | xen_pv |
