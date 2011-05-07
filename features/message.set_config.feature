Feature: Send set config messages

  As a Trema user
  I want to send set config messages to openflow switches
  So that I can set configuration parameters of openflow switches

  Background:
    Given I terminated all trema services

  Scenario: set config x 10
    When I try trema run "./objects/examples/openflow_message/set_config 10" with following configuration:
      """
      vswitch {
        datapath_id "0xabc"
      }
      """
      And wait until "set_config" is up
      And I terminated all trema services
    Then the log file "./tmp/log/openflowd.0xabc.log" should include "received: set_config" x 11
