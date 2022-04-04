@schema_metadata
@OpenData
Feature: SchemaMetadata


    Scenario: When a go to the dataset new page, the field field-author_email should not be visible
        Given "SysAdmin" as the persona
        When I log in
        And I go to "/dataset/new"
        Then I should see an element with id "field-author_email"

    Scenario: When a go to the dataset new page, the field field-maintainer_email should not be visible
        Given "SysAdmin" as the persona
        When I log in
        And I go to "/dataset/new"
        Then I should not see an element with id "field-maintainer_email"

    Scenario: When I create resource without a description, I should see an error for the missing description
        Given "SysAdmin" as the persona
        When I log in
        And I resize the browser to 1024x2048
        And I go to "/dataset/new_resource/warandpeace"
        And I press the element with xpath "//button[contains(string(), 'Add')]"
        Then I should see "Description: Missing value"

    Scenario: When I create resource without a name, I should see an error for the missing name
        Given "SysAdmin" as the persona
        When I log in
        And I resize the browser to 1024x2048
        When I visit "/dataset/new_resource/warandpeace"
        And I press the element with xpath "//button[contains(string(), 'Add')]"
        Then I should see "Name: Missing value"

    Scenario: When viewing the HTML source code of a dataset page, the structured data script is visible
        Given "SysAdmin" as the persona
        When I log in
        When I go to "/dataset/warandpeace"
        Then I should see an element with xpath "//link[@type='application/ld+json']"

    Scenario Outline: Check value of de_identified_data dropdown field
        Given "<User>" as the persona
        When I log in
        And I go to "/dataset/new"
        Then I should see an element with id "field-de_identified_data"
        Then I should see an element with xpath "//select[@id='field-de_identified_data']/option[@value='YES']"
        Then I should see an element with xpath "//select[@id='field-de_identified_data']/option[@value='NO']"
        Then I should see an element with xpath "//select[@id='field-de_identified_data']/option[@value='']"
        Then I should not see an element with xpath "//select[@id='field-de_identified_data']/option[@selected='' and  @value='YES']"
        Then I should not see an element with xpath "//select[@id='field-de_identified_data']/option[@selected='' and  @value='NO']"
        Then I should not see an element with xpath "//select[@id='field-de_identified_data']/option[@selected='' and  @value='']"

        Examples: Users
            | User          |
            | SysAdmin      |
            | TestOrgAdmin  |
            | TestOrgEditor |


    Scenario Outline: Edit existing dataset, field de_identified_data value should be NO
        Given "<User>" as the persona
        When I log in
        And I go to "/dataset/edit/warandpeace"
        Then I should see an element with id "field-de_identified_data"
        Then I should see an element with xpath "//select[@id='field-de_identified_data']/option[@value='YES']"
        Then I should see an element with xpath "//select[@id='field-de_identified_data']/option[@selected='' and @value='NO']"

        Examples: Users
            | User          |
            | SysAdmin      |
            | TestOrgAdmin  |
            | TestOrgEditor |

    Scenario Outline: When viewing existing dataset, field de_identified_data should be NO
        Given "<User>" as the persona
        When I log in

        And I go to "/dataset/warandpeace"
        Then I should see "Contains de-identified data"
        Then I should see an element with xpath "//th[contains(text(), 'Contains de-identified data')]/following-sibling::td[contains(text(), 'NO')]"

        When I go to "/api/3/action/package_show?id=warandpeace"
        Then I should see an element with xpath "//body/*[contains(text(), '"de_identified_data":')]"

        Examples: Users
            | User          |
            | SysAdmin      |
            | TestOrgAdmin  |
            | TestOrgEditor |

    Scenario: Non logged-in user should not see de_identified_data value.
        Given "Unauthenticated" as the persona
        When I go to "/dataset/warandpeace"
        Then I should not see "Contains de-identified data"
        Then I should not see an element with xpath "//th[contains(text(), 'Contains de-identified data')]/following-sibling::td[contains(text(), 'NO')]"

        And I go to "/api/3/action/package_show?id=warandpeace"
        Then I should not see an element with xpath "//body/*[contains(text(), '"de_identified_data":')]"

