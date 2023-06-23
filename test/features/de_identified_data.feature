@schema_metadata
@OpenData
Feature: De-identified data

    Scenario Outline: An editor, admin or sysadmin user, when I go to the dataset new page, the field field-de_identified_data should be visible with the correct values
        Given "<User>" as the persona
        When I log in
        And I go to "/dataset/new"
        Then I should see an element with id "field-de_identified_data"
        Then I should see an element with xpath "//select[@id='field-de_identified_data']/option[@value='YES']"
        Then I should see an element with xpath "//select[@id='field-de_identified_data']/option[@value='NO']"
        Then I should not see an element with xpath "//select[@id='field-de_identified_data']/option[@selected='' and  @value='YES']"
        Then I should not see an element with xpath "//select[@id='field-de_identified_data']/option[@selected='' and  @value='NO']"

        Examples: Users
            | User          |
            | TestOrgAdmin  |
            | TestOrgEditor |

    Scenario Outline: An editor, admin or sysadmin user, when I go to the edit dataset page, the field field-de_identified_data should be visible with the correct values
        Given "<User>" as the persona
        When I log in
        And I edit the "public-test-dataset" dataset
        Then I should see an element with id "field-de_identified_data"
        Then I should see an element with xpath "//select[@id='field-de_identified_data']/option[@value='YES']"
        Then I should see an element with xpath "//select[@id='field-de_identified_data']/option[@selected='' and @value='NO']"

        Examples: Users
            | User          |
            | TestOrgAdmin  |
            | TestOrgEditor |

    Scenario Outline: An editor, admin or sysadmin user can view the de-identified data
        Given "<User>" as the persona
        When I log in

        And I go to dataset "public-test-dataset"
        Then I should see "Contains de-identified data"
        And I should see an element with xpath "//th[contains(string(), 'Contains de-identified data')]/following-sibling::td[contains(string(), 'NO')]"

        When I go to "/api/3/action/package_show?id=public-test-dataset"
        Then I should see an element with xpath "//body/*[contains(string(), '"de_identified_data":')]"

        Examples: Users
            | User          |
            | TestOrgAdmin  |
            | TestOrgEditor |

    @unauthenticated
    Scenario: Unauthenticated user cannot view the de-identified data
        Given "Unauthenticated" as the persona
        When I go to dataset "public-test-dataset"
        Then I should not see "Contains de-identified data"
        And I should not see an element with xpath "//th[contains(string(), 'Contains de-identified data')]/following-sibling::td[contains(string(), 'NO')]"

        When I go to "/api/3/action/package_show?id=public-test-dataset"
        Then I should not see an element with xpath "//body/*[contains(string(), '"de_identified_data":')]"
