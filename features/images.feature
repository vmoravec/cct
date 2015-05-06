@images
Feature: OpenStack Image management
  As an administrator
  I want to make sure that OpenStack Image management component
  is working correctly

  Background:
    Given glance image does not exist

  @kvm
  Scenario: Creating and deleting KVM image
    Given KVM source image exists
    When I create new glance image based on jeos
    Then this image has non-empty ID
    And its ID can be used to show the image info
    And the status of the image is active
    And the image can be deleted

  @xen_hvm
  Scenario: Creating and deleting XEN HVM image
    Given XEN HVM source image exists
    When I create new glance image based on jeos
    Then this image has non-empty ID
    And its ID can be used to show the image info
    And the status of the image is active
    And the image can be deleted

  @xen_pv
  Scenario: Creating and deleting XEN PV image
    Given XEN PV source image exists
    When I create new glance image based on jeos
    Then this image has non-empty ID
    And its ID can be used to show the image info
    And the status of the image is active
    And the image can be deleted
