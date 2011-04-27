Feature: run trema application with `trema run' command

  As a Trema user
  I want to launch trema application with `trema run' command
  So that I don't have to mind DIRTY details of Trema

  Background:
    Given I terminated all trema services

  Scenario: trema run learning_switch
    When I try trema run with following configuration:
      """
      vswitch {
        datapath_id "0xabc"
      }

      app {
        path "./objects/examples/dumper/dumper"
      }
      """
      And wait until "dumper" is up
    Then switch_manager is started
      And dumper is started

  Scenario: `trema run' kills running process first
    Given I started switch_manager
    When I try trema run with following configuration:
      """
      vswitch {
        datapath_id "0xabc"
      }
      """
      And *** sleep 5 ***
    Then switch_manager should be killed
    
  Scenario: trema run learning_switch --verbose
    When I try trema run with following configuration:
      """
      vswitch {
        datapath_id "0xabc"
      }

      app {
        path "./objects/examples/learning_switch/learning_switch"
        options "--datapath_id", "0xabc"
      }
      """
      And wait until "learning_switch" is up
    Then "switch_manager" should be executed with option = "--daemonize --port=6633 -- port_status::learning_switch packet_in::learning_switch state_notify::learning_switch"
      And "learning_switch" should be executed with option = "--name learning_switch --datapath_id 0xabc"

  Scenario: trema help run
    When I try to run "./trema help run"
    Then the output should be:
      """
      Usage: ./trema run [OPTIONS ...]
          -c, --conf FILE
          -d, --daemonize

          -h, --help
          -v, --verbose

      """