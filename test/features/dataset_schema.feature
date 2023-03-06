@OpenData
Feature: Dataset Schema

    Scenario Outline: Add new dataset metadata fields for default data schema validation
        Given "<User>" as the persona
        When I log in
        And I visit "/dataset/new"

        And I should see an element with xpath "//label[text()="Default data schema"]"
        And I should see an element with xpath "//label[@for="field-de_identified_data"]/following::div[@id="resource-schema-buttons"]"

        Then I should see "Upload"
        And I should see "Link"
        And I should see "JSON"

        And field "default_data_schema" should not be required
        And field "schema_upload" should not be required
        And field "schema_url" should not be required
        And field "schema_json" should not be required

        Then I should see an element with xpath "//div[@id="resource-schema-buttons"]/following::label[@for="field-validation_options"]"
        And field "validation_options" should not be required

        Examples: roles
        | User                 |
        | DataRequestOrgAdmin  |
        | DataRequestOrgEditor |

    @fixture.dataset_with_schema::name=package-with-schema
    Scenario: New field visibility on dataset Additional info
        Given "SysAdmin" as the persona
        When I log in
        And I go to dataset "package-with-schema"
        Then I should see an element with xpath "//th[@class="dataset-label" and text()="Default data schema"]/following::a[text()="View Schema File"]"
        Then I should see an element with xpath "//th[@class="dataset-label" and text()="Data schema validation options"]/following::td[@class="dataset-details" and text()="Field name 'validation_options' not in data"]"

    @fixture.dataset_with_schema::name=package-with-schema
    Scenario: New field visibility on dataset via API
        Given "SysAdmin" as the persona
        When I log in
        Then I visit "api/action/package_show?id=package-with-schema"
        And I should see an element with xpath "//body/*[contains(text(), '"default_data_schema":')]"
