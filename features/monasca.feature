Feature: Monasca - cloud monitoring
  As a monitoring service operator
  I want to perform various validations
  In order to verify the monitoring service functionality

  Scenario: Monitoring service is available
    Given the admin node is available 
    And monasca node is available
    And all monitoring services are enabled and running on the monasca node
      |Service name:                             |
      |zookeeper                                 |
      |openstack-monasca-log-agent               |
      |openstack-monasca-log-metrics             |
      |openstack-monasca-log-persister           |
      |openstack-monasca-log-transformer         |
      |openstack-monasca-thresh                  |
      |elasticsearch                             |
      |storm-nimbus                              |
      |storm-supervisor                          |
   #Then

