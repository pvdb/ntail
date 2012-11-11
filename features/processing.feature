Feature: ntail's file processing

  Scenario: ntail processes files
    When I run `ntail foo.log bar.log blegga.log`
    Then the output should contain exactly:
    """
    [INFO] now processing file foo.log
    [INFO] now processing file bar.log
    [INFO] now processing file blegga.log

    """
