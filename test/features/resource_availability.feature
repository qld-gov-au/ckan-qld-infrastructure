@resource_visibility
@OpenData
Feature: Re-identification risk governance acknowledgement or Resource visibility

    Scenario: Sysadmin creates datasets with de_identified_data, resource_visible and governance_acknowledgement values to test resource visibility feature
        Given "SysAdmin" as the persona
        When I log in
        And I create resource_availability test data with title:"Contains de-identified data YES visibility TRUE acknowledgment NO" de_identified_data:"YES" resource_name:"Hide Resource" resource_visible:"TRUE" governance_acknowledgement:"NO"
        And I create resource_availability test data with title:"Contains de-identified data NO visibility TRUE acknowledgment NO" de_identified_data:"NO" resource_name:"Show Resource" resource_visible:"TRUE" governance_acknowledgement:"NO"
        And I create resource_availability test data with title:"Contains de-identified data NO visibility FALSE acknowledgment NO" de_identified_data:"NO" resource_name:"Hide Resource" resource_visible:"FALSE" governance_acknowledgement:"NO"
        And I create resource_availability test data with title:"Contains de-identified data YES visibility TRUE acknowledgment YES" de_identified_data:"NO" resource_name:"Show Resource" resource_visible:"TRUE" governance_acknowledgement:"NO"


    Scenario Outline: Organisation users should see a hidden resource when de-identified data is YES and Resource visibility is TRUE and Acknowledgement is NO
        Given "<User>" as the persona
        When I log in
        And I go to "/dataset/contains-de-identified-data-yes-visibility-true-acknowledgment-no"
        And I press the element with xpath "//a[@title='Hide Resource']"
        Then I should see an element with xpath "//th[contains(text(), 'Resource visible')]"
        And I should see an element with xpath "//th[contains(text(), 'Re-identification risk governance completed?')]"

        Examples: Users
            | User          |
            | SysAdmin      |
            | TestOrgAdmin  |
            | TestOrgEditor |

    Scenario: Unauthenticated user should not see a hidden resource when de-identified data is YES and Resource visibility is TRUE and Acknowledgement is NO
        When I go to "/dataset/contains-de-identified-data-yes-visibility-true-acknowledged-no"
        Then I should not see an element with xpath "//a[@title='Hide Resource']"

    Scenario Outline: Organisation users should see a visible resource when de-identified data is NO and Resource visibility is TRUE and Acknowledgement is NO
        Given "<User>" as the persona
        And I log in
        And I go to "/dataset/contains-de-identified-data-no-visibility-true-acknowledgment-no"
        And I press the element with xpath "//a[@title='Show Resource']"
        Then I should see an element with xpath "//th[contains(text(), 'Resource visible')]"
        And I should see an element with xpath "//th[contains(text(), 'Re-identification risk governance completed?')]"

        Examples: Users
            | User          |
            | SysAdmin      |
            | TestOrgAdmin  |
            | TestOrgEditor |

    Scenario: Unauthenticated user should see a visible resource when de-identified data is NO and Resource visibility is TRUE and Acknowledgement is NO
        When I go to "/dataset/contains-de-identified-data-no-visibility-true-acknowledgment-no"
        And I press the element with xpath "//a[@title='Show Resource']"
        Then I should not see an element with xpath "//th[contains(text(), 'Resource visible')]"
        And I should not see an element with xpath "//th[contains(text(), 'Re-identification risk governance completed?')]"

    Scenario Outline: Organisation users should see a hidden resource when de-identified data is NO and Resource visibility is FALSE and Acknowledgement is NO
        Given "<User>" as the persona
        When I log in
        And I go to "/dataset/contains-de-identified-data-no-visibility-false-acknowledgment-no"
        And I press the element with xpath "//a[@title='Hide Resource']"
        Then I should see an element with xpath "//th[contains(text(), 'Resource visible')]"
        And I should see an element with xpath "//th[contains(text(), 'Re-identification risk governance completed?')]"

        Examples: Users
            | User          |
            | SysAdmin      |
            | TestOrgAdmin  |
            | TestOrgEditor |

    Scenario: Unauthenticated user should not see a hidden visible resource when de-identified data is NO and Resource visibility is FALSE and Acknowledgement is NO
        When I go to "/dataset/contains-de-identified-data-no-visibility-false-acknowledgment-no"
        Then I should not see an element with xpath "//a[@title='Hide Resource']"


    Scenario Outline: Organisation users should see a visible resource when de-identified data is YES and Resource visibility is TRUE and Acknowledgement is YES
        Given "<User>" as the persona
        When I log in
        And I go to "/dataset/contains-de-identified-data-yes-visibility-true-acknowledgment-yes"
        And I press the element with xpath "//a[@title='Show Resource']"
        Then I should see an element with xpath "//th[contains(text(), 'Resource visible')]"
        And I should see an element with xpath "//th[contains(text(), 'Re-identification risk governance completed?')]"

        Examples: Users
            | User          |
            | SysAdmin      |
            | TestOrgAdmin  |
            | TestOrgEditor |

    Scenario: Unauthenticated user should see a visible resource when de-identified data is YES and Resource visibility is TRUE and Acknowledgement is YES
        When I go to "/dataset/contains-de-identified-data-yes-visibility-true-acknowledgment-yes"
        And I press the element with xpath "//a[@title='Show Resource']"
        Then I should not see an element with xpath "//th[contains(text(), 'Resource visible')]"
        And I should not see an element with xpath "//th[contains(text(), 'Re-identification risk governance completed?')]"


    Scenario Outline: Create resource and verify default values are set correct for resource visibility
        Given "<User>" as the persona
        When I create a resource with name "Resource created by <User> with default values" and URL "https://example.com"
        And I press the element with xpath "//a[@title='Resource created by <User> with default values']"
        Then I should not see "Visibility/Governance Acknowledgment"
        And I should see an element with xpath "//th[contains(text(), 'Resource visible')]/following-sibling::td[contains(text(), 'TRUE')]"
        And I should see an element with xpath "//th[contains(text(), 'Re-identification risk governance completed?')]/following-sibling::td[contains(text(), 'NO')]"

        Examples: Users
            | User          |
            | SysAdmin      |
            | TestOrgAdmin  |
            | TestOrgEditor |
