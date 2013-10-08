Feature: ntail's filename and line_number logging

  Scenario: ntail keeps track of filenames and line numbers
    Given a file named "blegga.log" with:
          """
          foo
          bar
          qux
          thud
          """
    Given a file named "thud.log" with:
          """
          x
          """
     When I run `ntail --log-level debug blegga.log thud.log`
     Then the output should contain all of these:
          | blegga.log:1 - 3 characters |
          | blegga.log:2 - 3 characters |
          | blegga.log:3 - 3 characters |
          | blegga.log:4 - 4 characters |
          | thud.log:1 - 1 character    |

