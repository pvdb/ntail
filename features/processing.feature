Feature: ntail's file processing

  Scenario: ntail processes files
    When I run `ntail foo.log bar.log blegga.log`
    Then the output should contain all of these:
         | now processing: foo.log    |
         | now processing: bar.log    |
         | now processing: blegga.log |
