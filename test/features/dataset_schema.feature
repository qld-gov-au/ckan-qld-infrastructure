@dataset_schema
@OpenData
Feature: Dataset Schema

    Scenario Outline: Add new dataset metadata fields for default data schema validation
        Given "<User>" as the persona
        When I log in
        And I visit "/dataset/new"

        Then I should see an element with xpath "//label[string()="Default data schema"]"
        And I should see an element with xpath "//label[@for="field-de_identified_data"]/following::div[@id="resource-schema-buttons"]"

        And I should see an element with xpath "//input[@name='schema_upload']"
        And I should see an element with xpath "//input[@name='schema_url']"
        And I should see an element with xpath "//textarea[@name='schema_json']"

        And field "default_data_schema" should not be required
        And field "schema_upload" should not be required
        And field "schema_url" should not be required
        And field "schema_json" should not be required

        Then I should see an element with xpath "//div[@id="resource-schema-buttons"]/following::label[@for="field-validation_options"]"
        And field "validation_options" should not be required

        Examples: roles
        | User                 |
        | TestOrgAdmin  |
        | TestOrgEditor |

    Scenario: New field visibility on dataset Additional info and API
        Given "SysAdmin" as the persona
        When I log in
        And I create a dataset and resource with key-value parameters "schema_json=default" and "url=default"
        Then I should see an element with xpath "//th[@class="dataset-label" and string()="Default data schema"]/following::a[string()="View Schema File"]"
        Then I should see an element with xpath "//th[@class="dataset-label" and string()="Data schema validation options"]/following::td[@class="dataset-details" and string()="[blank]"]"
        When I visit "api/action/package_show?id=$last_generated_name"
        Then I should see an element with xpath "//body/*[contains(string(), '"default_data_schema":')]"
