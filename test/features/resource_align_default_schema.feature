@dataset_schema
@OpenData
Feature: Resource align_default_schema field

    Scenario: Create or edit resource in the GUI where default_data_schema is NULL, initial display and behaviour
        Given "TestOrgEditor" as the persona
        When I log in
        And I create a dataset and resource with key-value parameters "schema_json=" and "name=Resource without default schema::upload=default::format=CSV"
        And I go to dataset "$last_generated_name"
        Then I should see an element with xpath "//th[@class="dataset-label" and string()="Default data schema"]/following-sibling::td[contains(string(), "[blank]")]"

        When I press "Resource without default schema"
        And I press the resource edit button
        Then I should not see "Align this data schema with the dataset default"
        And I should see an element with xpath "//div[@id='resource-schema-buttons']/label[contains(string(), 'Data Schema')]"
        When I show the non-JavaScript schema fields
        Then I should see "Upload Data Schema"
        And I should see "Data Schema URL"
        And I should see "Data Schema JSON definition"

        When I open the new resource form for dataset "$last_generated_name"
        Then I should not see "Align this data schema with the dataset default"
        When I show the non-JavaScript schema fields
        Then I should see "Upload Data Schema"
        And I should see "Data Schema URL"
        And I should see "Data Schema JSON definition"

    Scenario: Create resource with schema not aligned to default schema
        Given "TestOrgEditor" as the persona
        When I log in
        And I create a dataset with key-value parameters "schema_json=default"
        Then I should see an element with xpath "//th[@class="dataset-label" and string()="Default data schema"]/following::a[contains(string(), "View Schema File")]"

        When I open the new resource form for dataset "$last_generated_name"
        Then I should see an element with xpath "//div[contains(@class,'schema-align')]/following-sibling::div[@class='image-upload']"
        And I should see an element with xpath "//input[@type='checkbox' and @name='align_default_schema' and @checked]/following-sibling::label[@for='field-align_default_schema' and contains(string(), 'Align this data schema with the dataset default')]"
        And I should see an element with xpath "//div[@class="info-block " and contains(string(), "This data schema value is not aligned with a default data schema. Aligning this resource’s data schema with the dataset’s default data schema (and overwriting any pre-existing schema) ensures consistent validation of data structure.")]"
        And I should see an element with xpath "//div[@class="info-block " and contains(string(), "Alternatively, publishers can choose no alignment and may include a customised schema for this resource. Ticking this box and updating the resource will align the schemas, overwriting any existing data schema. The validation options, if any, will not be overwritten.")]"
        And field "align_default_schema" should not be required

        When I create a resource with key-value parameters "name=Unaligned resource::align_default_schema=False::upload=csv_resource.csv::format=CSV"
        And I press "Unaligned resource"
        Then I should see an element with xpath "//th[string()='Aligned with default data schema']/following-sibling::td[string()='FALSE']"

    Scenario: Edit a resource in the GUI where default schema exists
        Given "TestOrgEditor" as the persona
        When I log in
        And I create a dataset and resource with key-value parameters "schema_json=default" and "name=another-resource::schema=default::align_default_schema=False"
        Then I should see an element with xpath "//th[@class="dataset-label" and string()="Default data schema"]/following::a[contains(string(), "View Schema File")]"

        # Default and resource schema are different

        When I press "another-resource"
        Then I should see an element with xpath "//th[string()='Aligned with default data schema']/following-sibling::td[string()='FALSE']"
        When I click the link with text "View Schema File"
        Then I should see an element with xpath "//body[contains(string(), '"Resource schema"')]"

        When I go back
        And I press the resource edit button
        Then I should see "Align this data schema with the dataset default"
        And I should see an element with xpath "//input[@name='align_default_schema' and not(@checked)]"

        When I set the resource schema to the dataset default
        And I press "Update Resource"
        Then I should see an element with xpath "//th[string()='Aligned with default data schema']/following-sibling::td[translate(string(), 'true', 'TRUE')='TRUE']"
        When I click the link with text "View Schema File"
        Then I should see an element with xpath "//body[contains(string(), '"Default schema"')]"

        # now default and resource schema are the same

        When I go back
        And I press the resource edit button
        Then I should see "Align this data schema with the dataset default"
        And I should see an element with xpath "//input[@name='align_default_schema' and @checked]"

        When I uncheck "align_default_schema"
        And I execute the script "$('#field-schema-json ~ a.btn-remove-url').click()"
        And I execute the script "$('#field-schema-json').val('{"fields": [{"format": "default", "name": "Foo", "type": "string"}], "missingValues": ["Baz"]}')"
        And I take a debugging screenshot
        And I press "Update Resource"
        And I click the link with text "View Schema File"
        Then I should see an element with xpath "//body[contains(string(), '"Baz"')]"
        When I go back
        Then I should see an element with xpath "//th[string()='Aligned with default data schema']/following-sibling::td[translate(string(), 'false', 'FALSE')='FALSE']"
        When I press the resource edit button
        And I check "align_default_schema"
        And I press "Update Resource"
        Then I should see an element with xpath "//th[string()='Aligned with default data schema']/following-sibling::td[translate(string(), 'true', 'TRUE')='TRUE']"
