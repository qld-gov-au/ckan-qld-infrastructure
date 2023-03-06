@OpenData
Feature: Schema Generation
    Enable worker with `ckan jobs clear && ckan jobs worker`, since these tests rely on background tasks

    @fixture.dataset_with_schema::name=package-with-csv-res::owner_org=test-organisation
    @fixture.create_resource_for_dataset_with_params::package_id=package-with-csv-res::xloader=True
    Scenario: GUI for creating a data schema but not yet generated
        Given "TestOrgEditor" as the persona
        When I log in
        And I go to dataset "package-with-csv-res"
        Then I press the element with xpath "//li[@class="resource-item"]/a"
        Then I visit resource schema generation page
        And I reload page every 3 seconds until I see an element with xpath "//ul[@class="nav nav-tabs"]/li[position()=2]/a[text()[contains(.,'Data Schema')]]" but not more than 6 times
        And I should see an element with xpath "//button[text()[contains(.,'Generate JSON data schema')]]"
        And I should see an element with xpath "//button[contains(@class, 'btn-generate')]/following::table[contains(@class, 'table-schema')]"
        And I should see an element with xpath "//th[string()='Status']/following::td[string()='Not generated']"
        And I should see an element with xpath "//th[string()='Last updated']/following::td[string()='Never']"

    @fixture.dataset_with_schema::name=package-with-csv-res::owner_org=test-organisation
    @fixture.create_resource_for_dataset_with_params::package_id=package-with-csv-res::xloader=True
    Scenario: Data schema creation tool is triggered and data is suitable for generating a schema.
        Given "TestOrgEditor" as the persona
        When I log in
        And I go to dataset "package-with-csv-res"
        Then I press the element with xpath "//li[@class="resource-item"]/a"
        Then I visit resource schema generation page
        And I reload page every 3 seconds until I see an element with xpath "//ul[@class="nav nav-tabs"]/li[position()=2]/a[text()[contains(.,'Data Schema')]]" but not more than 6 times
        And I press the element with xpath "//button[text()[contains(.,'Generate JSON data schema')]]"
        Then I reload page every 3 seconds until I see an element with xpath "//th[string()='Status']/following::td[string()='Pending']" but not more than 6 times
        And I should see an element with xpath "//th[string()='Last updated']/following::td/span[text()[contains(.,'Just now')]]"

    @fixture.dataset_with_schema::name=package-with-csv-res::owner_org=test-organisation
    @fixture.create_resource_for_dataset_with_params::package_id=package-with-csv-res::xloader=True
    Scenario: GUI for creating/displaying a data schema where previously successfully generated
        Given "TestOrgEditor" as the persona
        When I log in
        And I go to dataset "package-with-csv-res"
        Then I press the element with xpath "//li[@class="resource-item"]/a"
        Then I visit resource schema generation page
        And I reload page every 3 seconds until I see an element with xpath "//ul[@class="nav nav-tabs"]/li[position()=2]/a[text()[contains(.,'Data Schema')]]" but not more than 6 times
        And I press the element with xpath "//button[text()[contains(.,'Generate JSON data schema')]]"
        And I reload page every 3 seconds until I see an element with xpath "//button[text()='Apply']" but not more than 6 times

        And I should see an element with xpath "//th[string()='Status']/following::td[string()='Complete']"
        And I should see an element with xpath "//th[string()='Last updated']/following::td/span[text()[contains(.,'seconds ago')]]"
        And I should see an element with xpath "//th[string()='JSON data schema']/following::td[@class="with-textarea"]"
        And I should see an element with xpath "//table[contains(@class, 'table-schema')]/following::label[string()="Enable validation of resource/s using this data schema at the following level"]"
        And I should see an element with xpath "//table[contains(@class, 'table-schema')]/following::select[@id="field-apply_for"]"
        Then I should see an element with xpath "//select[@id='field-apply_for']/option[@value=''][1]"
        Then I should see an element with xpath "//select[@id='field-apply_for']/option[text()='Dataset default' and not(@selected)]"
        Then I should see an element with xpath "//select[@id='field-apply_for']/option[text()='Resource' and not(@selected)]"

        And I should see an element with xpath "//div/following::p[text()[contains(.,'Leaving blank will NOT change any pre-existing validation for this dataset or resource.')]]"
        And I should see an element with xpath "//div/following::p[text()[contains(.,'Once applied as the "Dataset default", all dataset resources, when edited or added, will be validated against this data schema.')]]"
        And I should see an element with xpath "//div/following::p[text()[contains(.,'Once applied to only this "Resource", saved edits will be validated against this data schema unless otherwise overwritten (e.g. Dataset default set).')]]"

        And I should see an element with xpath "//button[text()='Apply']"

    @fixture.dataset_with_schema::name=package-with-csv-res::owner_org=test-organisation
    @fixture.create_resource_for_dataset_with_params::package_id=package-with-csv-res::xloader=True
    Scenario: System actions following the selection of the blank dropdown option on the manage data schema GUI page
        Given "TestOrgEditor" as the persona
        When I log in
        And I go to dataset "package-with-csv-res"
        Then I press the element with xpath "//li[@class="resource-item"]/a"
        Then I visit resource schema generation page
        And I reload page every 3 seconds until I see an element with xpath "//ul[@class="nav nav-tabs"]/li[position()=2]/a[text()[contains(.,'Data Schema')]]" but not more than 6 times
        And I press the element with xpath "//button[text()[contains(.,'Generate JSON data schema')]]"
        And I reload page every 3 seconds until I see an element with xpath "//button[text()='Apply']" but not more than 6 times
        And I press the element with xpath "//button[text()='Apply']"
        Then I should see an element with xpath "//select[@id='field-apply_for']/option[@value=''][1]"
        And I should see an element with xpath "//select[@id='field-apply_for']/option[text()='Dataset default' and not(@selected)]"
        And I should see an element with xpath "//select[@id='field-apply_for']/option[text()='Resource' and not(@selected)]"

    @fixture.dataset_with_schema::name=package-with-csv-res::owner_org=test-organisation
    @fixture.create_resource_for_dataset_with_params::package_id=package-with-csv-res::xloader=True
    Scenario: System actions following the selection of the set as dataset default dropdown option on the manage data schema GUI page
        Given "TestOrgEditor" as the persona
        When I log in
        And I go to dataset "package-with-csv-res"
        Then I press the element with xpath "//li[@class="resource-item"]/a"
        Then I visit resource schema generation page
        And I reload page every 3 seconds until I see an element with xpath "//ul[@class="nav nav-tabs"]/li[position()=2]/a[text()[contains(.,'Data Schema')]]" but not more than 6 times
        And I press the element with xpath "//button[text()[contains(.,'Generate JSON data schema')]]"
        And I reload page every 3 seconds until I see an element with xpath "//button[text()='Apply']" but not more than 6 times
        Then I select "dataset" from "apply_for"
        And I press the element with xpath "//button[text()='Apply']"
        And I go to dataset "package-with-csv-res"
        Then I should see an element with xpath "//th[@class="dataset-label" and text()="Default data schema"]/following::a[text()="View Schema File"]"


    @fixture.dataset_with_schema::name=package-with-csv-res::owner_org=test-organisation
    @fixture.create_resource_for_dataset_with_params::package_id=package-with-csv-res::xloader=True
    Scenario: System actions following the selection of the validate only this resource dropdown option on the manage data schema GUI page
        Given "TestOrgEditor" as the persona
        When I log in
        And I go to dataset "package-with-csv-res"
        Then I press the element with xpath "//li[@class="resource-item"]/a"
        Then I visit resource schema generation page
        And I reload page every 3 seconds until I see an element with xpath "//ul[@class="nav nav-tabs"]/li[position()=2]/a[text()[contains(.,'Data Schema')]]" but not more than 6 times
        And I press the element with xpath "//button[text()[contains(.,'Generate JSON data schema')]]"
        And I reload page every 3 seconds until I see an element with xpath "//button[text()='Apply']" but not more than 6 times
        Then I select "resource" from "apply_for"
        And I press the element with xpath "//button[text()='Apply']"

        And I press the element with xpath "//a[text()[contains(.,'View resource')]]"
        Then I should see an element with xpath "//th[text()="Data Schema"]/following::a[text()="View Schema File"]"
