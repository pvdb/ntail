Feature: ntail's filename and line_number logging

  Scenario: ntail keeps track of filenames and line numbers
    Given a file named "blegga.log" with:
          """
          foo
          bar
          blegga
          """
    Given a file named "thud.log" with:
          """
          qux
          thud
          """
     When I run `ntail --log-level debug blegga.log thud.log`
     Then the output should contain all of these:
          | blegga.log:1 |
          | blegga.log:2 |
          | blegga.log:3 |
          | thud.log:1   |
          | thud.log:2   |

