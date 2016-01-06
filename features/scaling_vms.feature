# You need to set the environment variable $cct_vm_number before running this feature
# If your cloud doesn't have the same number of floating IPs as VMs available, set
# the variable $cct_fip_number; floating IPs will be assigned to VMs picked randomly
# from the created pool of VMs. Additionally you can set the way how the VMs are
# going to be spawned, you either can rely on openstack managing the VMs' spawning
# processt_vm_delay to delay the VMs' booting process by number of seconds.
#
# Configuration:
# ===================================================================================
# $cct_vm_number     => number of VMs to spawn, default is 10
# $cct_fip_number    => number of floating IPs to be assigned to the created VMs, optional
# $cct_wait_for_vm   => optional, default is 1;
# $cct_vm_reserve    => optional, default is 3; increases the quotas due to VMs leftovers

@scaling_vms
Feature: Scaling VMs
  As a cloud administrator
  I want to verify the cloud can scale to VMs count defined by VM_COUNT env variable
  In order to make sure the cloud components work properly

  Background:
    Given the environment variable "cct_vm_number" is set
    And the variable "cct_vm_number" has value greater than zero
    And necessary rules for "default" security group on port "22" are present
    And necessary rules for "default" security group on "ipmc" protocol are present
    And "default" quotas for cores and instances in project "openstack" have been updated
    And respective quotas for nova in project "openstack" have been updated
    And respective quotas for neutron in project "openstack" have been updated

  @cirros
  Scenario: Scaling with cirros image
    Given the image named "cirros-.*x86_64.*-machine" is available
    And the flavor "cirros-test" is defined
    And the key pair "cirros-test" has been created
    And there are no VMs with the name "cirros-test-vm" present
    When I request creating VMs with name "cirros-test-vm"
    Then I get all the VMs listed as "ACTIVE"
    And  there are enough floating IPs available
    And  I assign floating IPs to the VMs
    And  I can ping running VMs
    And  I ssh to VMs successfully as "cirros" user
    And  I remove the floating IPs from all VMs
    And  I delete floating IPs from the pool
    And  I delete all the VMs used for testing
