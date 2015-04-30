@glance
Feature: Glance
  As an administrator
  I want to make sure that Glance component is working correctly

  @create_kvm_image
  Scenario: Creation of KVM image
    Given KVM source image exists
    And glance image does not exist
    When I create new glance image based on jeos
    Then this image has non-empty ID
    And its ID can be used to show the image info
    And the status of the image is active
    When I delete the image
    Then it is no longer listed

  @create_xen_hvm_image
  Scenario: Creation of XEN HVM image
    Given XEN HVM source image exists
    And glance image does not exist
    When I create new glance image based on jeos
    Then this image has non-empty ID
    And its ID can be used to show the image info
    And the status of the image is active
    When I delete the image
    Then it is no longer listed

  @create_xen_pv_image
  Scenario: Creation of XEN PV image
    Given XEN PV source image exists
    And glance image does not exist
    When I create new glance image based on jeos
    Then this image has non-empty ID
    And its ID can be used to show the image info
    And the status of the image is active
    When I delete the image
    Then it is no longer listed


