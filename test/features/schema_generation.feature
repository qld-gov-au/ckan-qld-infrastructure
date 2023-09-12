@OpenData
Feature: Schema Generation
    Enable worker with `ckan jobs clear && ckan jobs worker`, since these tests rely on background tasks

    Scenario: As a publisher, when I visit my resource, I can generate a validation schema for it
        Given "TestOrgEditor" as the persona
        When I log in
        And I create a dataset and resource with key-value parameters "notes=package-with-csv-res::schema_json=default" and "upload=default::format=CSV"
        And I take a debugging screenshot
        And I go to the first resource in the dataset
        And I take a debugging screenshot
        # Ensure that the datastore is active
        And I reload page every 3 seconds until I see an element with xpath "//*[string() = 'Data Dictionary']" but not more than 6 times
        And I visit resource schema generation page
        And I take a debugging screenshot
        Then I should see an element with xpath "//button[contains(string(), 'Generate JSON data schema') and contains(@class, 'btn-generate')]/following::table[contains(@class, 'table-schema')]"
        And I should see an element with xpath "//th[string()='Status']/following::td[string()='Not generated']"
        And I should see an element with xpath "//th[string()='Last updated']/following::td[string()='Never']"

        When I press "Generate JSON data schema"
        And I take a debugging screenshot
        And I reload page every 3 seconds until I see an element with xpath "//th[string()='Status']/following::td[string()='Pending']" but not more than 6 times
        Then I should see an element with xpath "//th[string()='Last updated']/following::td/span[contains(@class, 'date')]"
        When I reload page every 3 seconds until I see an element with xpath "//button[string()='Apply']" but not more than 6 times
        Then I should see an element with xpath "//th[string()='Status']/following::td[string()='Complete']"
        And I should see an element with xpath "//th[string()='Last updated']/following::td/span[contains(@class, 'date')]"
        And I should see an element with xpath "//th[string()='JSON data schema']/following::td[@class="with-textarea"]"
        And I should see an element with xpath "//table[contains(@class, 'table-schema')]/following::label[string()="Enable validation of resource/s using this data schema at the following level"]"
        And I should see an element with xpath "//table[contains(@class, 'table-schema')]/following::select[@id="field-apply_for"]"
        And I should see an element with xpath "//select[@id='field-apply_for']/option[@value=''][1]"
        And I should see an element with xpath "//select[@id='field-apply_for']/option[string()='Dataset default' and not(@selected)]"
        And I should see an element with xpath "//select[@id='field-apply_for']/option[string()='Resource' and not(@selected)]"

        And I should see an element with xpath "//div/following::p[contains(string(), 'Leaving blank will NOT change any pre-existing validation for this dataset or resource.')]"
        And I should see an element with xpath "//div/following::p[contains(string(), 'Once applied as the "Dataset default", all dataset resources, when edited or added, will be validated against this data schema.')]"
        And I should see an element with xpath "//div/following::p[contains(string(), 'Once applied to only this "Resource", saved edits will be validated against this data schema unless otherwise overwritten (e.g. Dataset default set).')]"
        And I should see an element with xpath "//button[string()='Apply']"

        When I press the element with xpath "//button[string()='Apply']"
        Then I should see an element with xpath "//select[@id='field-apply_for']/option[@value=''][1]"
        And I should see an element with xpath "//select[@id='field-apply_for']/option[string()='Dataset default' and not(@selected)]"
        And I should see an element with xpath "//select[@id='field-apply_for']/option[string()='Resource' and not(@selected)]"

    Scenario: System actions following the selection of the set as dataset default dropdown option on the manage data schema GUI page
        Given "TestOrgEditor" as the persona
        When I log in
        And I create a dataset and resource with key-value parameters "notes=apply-for-dataset-schema::schema_json=default" and "upload=default::format=CSV"
        And I go to the first resource in the dataset
        And I reload page every 3 seconds until I see an element with xpath "//*[string() = 'Data Dictionary']" but not more than 6 times
        And I visit resource schema generation page
        Then I should see an element with xpath "//button[contains(string(), 'Generate JSON data schema') and contains(@class, 'btn-generate')]/following::table[contains(@class, 'table-schema')]"
        When I press "Generate JSON data schema"
        And I reload page every 3 seconds until I see an element with xpath "//button[string()='Apply']" but not more than 6 times
        And I select "dataset" from "apply_for"
        And I press the element with xpath "//button[string()='Apply']"
        And I go to dataset "$last_generated_name"
        And I show all the fields
        Then I should see an element with xpath "//th[@class="dataset-label" and string()="Default data schema"]/following::a[string()="View Schema File"]"

    Scenario: System actions following the selection of the validate only this resource dropdown option on the manage data schema GUI page
        Given "TestOrgEditor" as the persona
        When I log in
        And I create a dataset and resource with key-value parameters "notes=apply-for-resource-schema::schema_json=default" and "upload=default::format=CSV"
        And I go to the first resource in the dataset
        And I reload page every 3 seconds until I see an element with xpath "//*[string() = 'Data Dictionary']" but not more than 6 times
        And I visit resource schema generation page
        Then I should see an element with xpath "//button[contains(string(), 'Generate JSON data schema') and contains(@class, 'btn-generate')]/following::table[contains(@class, 'table-schema')]"
        When I press "Generate JSON data schema"
        And I reload page every 3 seconds until I see an element with xpath "//button[string()='Apply']" but not more than 6 times
        And I select "resource" from "apply_for"
        And I press the element with xpath "//button[string()='Apply']"
        And I press the element with xpath "//a[contains(string(), 'View resource')]"
        And I show all the fields
        Then I should see an element with xpath "//th[string()="Data Schema"]/following::a[string()="View Schema File"]"
