Feature: ntail's file processing

  Scenario: ntail processes files
    Given an empty file named "foo.log"
    Given an empty file named "bar.log"
    Given an empty file named "blegga.log"
     When I run `ntail foo.log bar.log blegga.log`
     Then the output should contain all of these:
          | now processing: foo.log    |
          | now processing: bar.log    |
          | now processing: blegga.log |

  Scenario: ntail counts files and lines
    Given a file named "blegga.log" with:
          """
          foo
          bar
          """
    Given a file named "qux.log" with:
          """
          thud
          """
     When I run `ntail blegga.log`
     Then the output should contain:
          """
          processed 2 line(s) in 1 file(s)
          """
     When I run `ntail qux.log`
     Then the output should contain:
          """
          processed 1 line(s) in 1 file(s)
          """
     When I run `ntail blegga.log qux.log`
     Then the output should contain:
          """
          processed 3 line(s) in 2 file(s)
          """

  Scenario: ntail counts files and lines, even with no input
     When I run `ntail`
     Then the output should contain:
          """
          processed 0 line(s) in 0 file(s)
          """
