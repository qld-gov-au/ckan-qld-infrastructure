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

    Scenario: When I create a resource without a name or description, I should see errors
        Given "SysAdmin" as the persona
        When I log in
        And I open the new resource form for dataset "public-test-dataset"
        And I enter the resource URL "https://example.com"
        And I press the element with xpath "//button[contains(string(), 'Add')]"
        Then I should see "Name: Missing value"
        And I should see "Description: Missing value"

    @unauthenticated
    Scenario: When viewing the HTML source code of a dataset page, the structured data script is visible
        Given "Unauthenticated" as the persona
        When I go to dataset "public-test-dataset"
        Then I should see an element with xpath "//link[@type='application/ld+json']"

    Scenario Outline: Check value of de_identified_data dropdown field
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

    Scenario Outline: Edit existing dataset, field de_identified_data value should be NO
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

    Scenario Outline: When viewing existing dataset, field de_identified_data should be NO
        Given "<User>" as the persona
        When I log in

        And I go to dataset "public-test-dataset"
        Then I should see "Contains de-identified data"
        Then I should see an element with xpath "//th[contains(string(), 'Contains de-identified data')]/following-sibling::td[contains(string(), 'NO')]"

        When I go to "/api/3/action/package_show?id=public-test-dataset"
        Then I should see an element with xpath "//body/*[contains(string(), '"de_identified_data":')]"

        Examples: Users
            | User          |
            | TestOrgAdmin  |
            | TestOrgEditor |

    @unauthenticated
    Scenario: Non logged-in user should not see de_identified_data value.
        Given "Unauthenticated" as the persona
        When I go to dataset "public-test-dataset"
        Then I should not see "Contains de-identified data"
        And I should not see an element with xpath "//th[contains(string(), 'Contains de-identified data')]/following-sibling::td[contains(string(), 'NO')]"

        When I go to "/api/3/action/package_show?id=public-test-dataset"
        Then I should not see an element with xpath "//body/*[contains(string(), '"de_identified_data":')]"

    Scenario Outline: Check label of the Data schema validation options field
        Given "<User>" as the persona
        When I log in
        And I open the new resource form for dataset "public-test-dataset"
        Then I should see an element with xpath "//label[string()='Data schema validation options']"
        Then I should not see an element with xpath "//label[string()='Validation options']"

        Examples: Users
          | User          |
          | TestOrgAdmin  |
          | TestOrgEditor |
