Feature: Resource align_default_schema field
    @fixture.dataset_with_schema::name=package-without-default-schema::default_data_schema=::owner_org=test-organisation
    @fixture.create_resource_for_dataset_with_params::package_id=package-without-default-schema::name=resource-one::schema=
    Scenario: Create or edit resource in the GUI where default_data_schema is NULL, initial display and behaviour
        Given "TestOrgEditor" as the persona
        When I log in
        Then I go to "/dataset/package-without-default-schema"
        Then I should see an element with xpath "//th[@class="dataset-label" and text()="Default data schema"]/following-sibling::td[contains(text(),"Field name 'default_data_schema' not in data")]"

        Then I press the element with xpath "//li[@class="resource-item"]/a"
        Then I press the element with xpath "//a[contains(text(),'Manage')]"
        And I should not see "Align this data schema with the dataset default"
        And I should see "Upload"
        And I should see "Link"
        And I should see "JSON"

        And I go to "/dataset/package-without-default-schema/resource/new"
        And I should not see "Align this data schema with the dataset default"
        And I should see "Upload"
        And I should see "Link"
        And I should see "JSON"


    @fixture.dataset_with_schema::name=package-without-default-schema::owner_org=test-organisation
    Scenario: Create resource with schema not aligned to default schema
        Given "TestOrgEditor" as the persona
        When I log in
        Then I go to "/dataset/package-without-default-schema"
        Then I should see an element with xpath "//th[@class="dataset-label" and text()="Default data schema"]/following::a[contains(text(),"View Schema File")]"

        And I go to "/dataset/package-without-default-schema/resource/new"

        And I should see an element with xpath "//div[contains(@class,'schema-align')]/following-sibling::div[@class='image-upload']"
        And I should see an element with xpath "//input[@type='checkbox' and @name='align_default_schema' and @checked]/following-sibling::label[@for='field-align_default_schema' and text()=contains(.,'Align this data schema with the dataset default')]"
        And I should see an element with xpath "//div[@class="info-block " and text()=contains(.,"This data schema value is not aligned with a default data schema. Aligning this resource’s data schema with the dataset’s default data schema (and overwriting any pre-existing schema) ensures consistent validation of data structure.")]"
        And I should see an element with xpath "//div[@class="info-block " and text()=contains(.,"Alternatively, publishers can choose no alignment and may include a customised schema for this resource. Ticking this box and updating the resource will align the schemas, overwriting any existing data schema. The validation options, if any, will not be overwritten.")]"
        And field "align_default_schema" should not be required

        Then I uncheck "align_default_schema"
        And I attach the file "csv_resource.csv" to "upload"
        And I fill in "name" with "Another resource"
        And I fill in "description" with "description"
        And I fill in "size" with "1024" if present

        And I press the element with xpath "//button[@class="btn btn-primary" and contains(string(), 'Add')]"

        Then I press the element with xpath "//li[@class="resource-item"]/a"
        Then I should see an element with xpath "//th[text()='Aligned with default data schema']/following-sibling::td[text()='FALSE']"

    @fixture.dataset_with_schema::name=package-without-default-schema::owner_org=test-organisation
    @fixture.create_resource_for_dataset_with_params::package_id=package-without-default-schema::name=another-resource
    Scenario: Edit a resource in the GUI where default_data_schema is not NULL and the existing schema value does not match the default_data_schema value
        Given "TestOrgEditor" as the persona
        When I log in
        Then I go to "/dataset/package-without-default-schema"
        Then I should see an element with xpath "//th[@class="dataset-label" and text()="Default data schema"]/following::a[contains(text(),"View Schema File")]"

        Then I press the element with xpath "//li[@class="resource-item"]/a"
        Then I should see an element with xpath "//th[text()='Aligned with default data schema']/following-sibling::td[text()='FALSE']"
        Then I click the link with text "View Schema File"
        And I should see an element with xpath "//body[contains(text(), '"Resource schema"')]"
        Then I go back

        Then I press the element with xpath "//a[contains(text(),'Manage')]"
        And I should see an element with xpath "//input[@type='checkbox' and @name='align_default_schema' and not(@checked)]/following-sibling::label[@for='field-align_default_schema' and text()=contains(.,'Align this data schema with the dataset default')]"

        Then I check "align_default_schema"
        And I press the element with xpath "//button[text()='Update Resource']"
        Then I should see an element with xpath "//th[text()='Aligned with default data schema']/following-sibling::td[text()='TRUE']"
        Then I click the link with text "View Schema File"
        And I should see an element with xpath "//body[contains(text(), '"Default schema"')]"

    @fixture.dataset_with_schema::name=package-without-default-schema::owner_org=test-organisation
    @fixture.create_resource_for_dataset_with_params::package_id=package-without-default-schema::name=another-resource::schema=
    Scenario: Edit resource in the GUI where default_data_schema is not NULL and the existing schema value matches the default_data_schema value
        Given "TestOrgEditor" as the persona
        When I log in
        Then I go to "/dataset/package-without-default-schema"
        Then I should see an element with xpath "//th[@class="dataset-label" and text()="Default data schema"]/following::a[contains(text(),"View Schema File")]"

        Then I press the element with xpath "//li[@class="resource-item"]/a"
        Then I should see an element with xpath "//th[text()='Aligned with default data schema']/following-sibling::td[text()='FALSE']"
        Then I press the element with xpath "//a[contains(text(),'Manage')]"
        And I should see "Align this data schema with the dataset default"
        And I execute the script "document.getElementById('field-schema').value='{"fields":[{"format": "default","name": "Game Number","type": "integer"},{"format": "default","name": "Game Length","type": "integer"}],"missingValues": ["Default schema"]}'"

        Then I press the element with xpath "//button[text()='Update Resource']"

        Then I should see an element with xpath "//th[text()='Aligned with default data schema']/following-sibling::td[text()='TRUE']"

        # now default and resource schema are the same
        Then I press the element with xpath "//a[contains(text(),'Manage')]"
        And I should not see "Align this data schema with the dataset default"

        # now default and resource schema are different
        Then I press the element with xpath "//textarea[@id='field-schema-json']/preceding-sibling::a[text()='Clear']"
        And I execute the script "document.getElementById('field-schema').value='{"fields":[{"format": "default","name": "Game Number","type": "integer"},{"format": "default","name": "Game Length","type": "integer"}], "missingValues": ["Resource schema"]}'"

        Then I press the element with xpath "//button[text()='Update Resource']"
        Then I press the element with xpath "//a[contains(text(),'Manage')]"

        And I should see "Align this data schema with the dataset default"
        Then I press the element with xpath "//button[text()='Update Resource']"

        Then I click the link with text "View Schema File"
        And I should see an element with xpath "//body[contains(text(), '"Resource schema"')]"
        Then I go back

        Then I press the element with xpath "//a[contains(text(),'Manage')]"
        And I should see an element with xpath "//input[@type='checkbox' and @name='align_default_schema' and not(@checked)]/following-sibling::label[@for='field-align_default_schema' and text()=contains(.,'Align this data schema with the dataset default')]"

        Then I check "align_default_schema"
        And I press the element with xpath "//button[text()='Update Resource']"
        Then I should see an element with xpath "//th[text()='Aligned with default data schema']/following-sibling::td[text()='TRUE']"
        Then I click the link with text "View Schema File"
        And I should see an element with xpath "//body[contains(text(), '"Default schema"')]"
