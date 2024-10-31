@resource_freshness
@OpenData
Feature: Resource freshness

    Scenario Outline: An editor, admin or sysadmin user, when I go to the dataset new page, the text 'Next update due' should not be visible
        Given "<User>" as the persona
        When I log in
        And I go to "/dataset/new"
        Then I should not see "Next update due"

        Examples: Users
            | User          |
            | SysAdmin      |
            | TestOrgAdmin  |
            | TestOrgEditor |

    Scenario Outline: An editor, admin or sysadmin user, when I go to the dataset new page and select an update frequency, then the text 'Next update due' should be visible
        Given "<User>" as the persona
        When I log in
        And I go to "/dataset/new"
        And I select "<Frequency>" from "update_frequency"
        Then I should see "Next update due"

        Examples: Frequencies
            | User          | Frequency     |
            | SysAdmin      | monthly       |
            | TestOrgAdmin  | biennially    |
            | TestOrgEditor | quadrennially |

    Scenario Outline: As a user with editing privileges, when I set a 'monthly' update frequently, I should still be able to update the dataset via the API
        Given "<User>" as the persona
        When I log in
        Then I should be able to patch dataset "test-dataset" via the API
        When I edit the "test-dataset" dataset
        And I select "monthly" from "update_frequency"
        Then I should see "Next update due"
        When I fill in "next_update_due" with "01/01/1970"
        And I press the element with xpath "//form[@id='dataset-edit']//button[contains(@class, 'btn-primary')]"
        And I wait for 3 seconds
        Then I should be able to patch dataset "test-dataset" via the API

        Examples: Users
            | User          |
            | SysAdmin      |
            | TestOrgAdmin  |
            | TestOrgEditor |
