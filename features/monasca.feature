Feature: Monasca - cloud monitoring
  As a monitoring service operator
  I want to perform various validations
  In order to verify the monitoring service functionality

  Background:
    Given the admin node is available
    And monasca node is available

  Scenario: Services are active and enabled
    Given all monitoring services are enabled and running on the monasca node
      |Service name:                             |
      |apache2                                   |
      |influxdb                                  |
      |elasticsearch                             |
      |kafka                                     |
      |kibana                                    |
      |memcached                                 |
      |mysql                                     |
      |openstack-monasca-agent                   |
      |openstack-monasca-log-agent               |
      |openstack-monasca-log-metrics             |
      |openstack-monasca-log-persister           |
      |openstack-monasca-log-transformer         |
      |openstack-monasca-notification            |
      |openstack-monasca-persister               |
      |openstack-monasca-thresh                  |
      |elasticsearch                             |
      |storm-nimbus                              |
      |storm-supervisor                          |
      |zookeeper                                 |

  Scenario: Monasca CLI client functionality
    Given the package "python-monascaclient" is installed
    When "monasca" command is available on controller node
    And openrc file is adapted for monasca
    Then all monasca subcommands containing list succeed
      |Subcommand:           |
      |alarm-list            |
      |alarm-definition-list |
      |alarm-history-list    |
      |dimension-name-list   |
     #|dimension-value-list  | needs argument DIMENSION_NAME, skipping..
     #|measurement-list      | needs argument METRIC_NAME, skipping..
      |metric-list           |
      |metric-name-list      |
      |notification-list     |
      |notification-type-list|

