Feature: ntail's line filtering

  Scenario: ntail counts processed lines
    Given a file named "blegga.log" with:
          """
          foo
          bar
          qux
          thud
          """
     When I run `ntail --filter true blegga.log`
     Then the output should contain all of these:
          | processed 4 line(s) in 1 file(s)        |
          | processed 4 lines, filtered out 0 lines |

  Scenario: ntail counts filtered lines
    Given a file named "blegga.log" with:
          """
          foo
          bar
          qux
          thud
          """
     When I run `ntail --filter false blegga.log`
     Then the output should contain all of these:
          | processed 4 line(s) in 1 file(s)        |
          | processed 0 lines, filtered out 4 lines |

  Scenario: ntail counts processed and filtered lines
    Given a file named "blegga.log" with:
          """
          foo
          bar
          qux
          thud
          """
     When I run `ntail --filter 'raw_log_line.length == 3' blegga.log`
     Then the output should contain all of these:
          | processed 4 line(s) in 1 file(s)        |
          | processed 3 lines, filtered out 1 lines |
