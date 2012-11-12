Feature: ntail's line matching

  Scenario: ntail counts unparsable lines
    Given a file named "blegga.log" with:
          """
          foo
          bar
          qux
          thud
          """
     When I run `ntail --pattern foobar blegga.log`
     Then the output should contain all of these:
          | processed 4 line(s) in 1 file(s)     |
          | 0 parsable lines, 4 unparsable lines |

  Scenario: ntail counts parsable lines
    Given a file named "blegga.log" with:
          """
          foo
          bar
          qux
          thud
          """
     When I run `ntail --pattern '[aeiou]' blegga.log`
     Then the output should contain all of these:
          | processed 4 line(s) in 1 file(s)     |
          | 4 parsable lines, 0 unparsable lines |

  Scenario: ntail counts parsable and unparsable lines
    Given a file named "blegga.log" with:
          """
          foo
          grr
          bar
          tch
          qux
          ntd
          thud
          """
     When I run `ntail --pattern '[aeiou]' blegga.log`
     Then the output should contain all of these:
          | processed 7 line(s) in 1 file(s)     |
          | 4 parsable lines, 3 unparsable lines |
