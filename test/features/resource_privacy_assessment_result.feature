Feature: Resource Privacy Assessment Result

    @fixture.dataset_with_schema::name=package-with-csv-res::owner_org=test-organisation
    @fixture.create_resource_for_dataset_with_params::package_id=package-with-csv-res
    Scenario: Add new resource metadata field 'Privacy assessment result' and display on the edit resource GUI page
        Given "TestOrgEditor" as the persona
        When I log in
        And I go to dataset "package-with-csv-res"

        Then I press the element with xpath "//li[@class="resource-item"]/a"
        Then I press the element with xpath "//a[text()[contains(.,'Manage')]]"
        And I should see an element with xpath "//select[@name='request_privacy_assessment']/following::label[text()='Privacy assessment result']"
        And I should see an element with xpath "//input[@name='privacy_assessment_result' and @readonly]"
        And I should see an element with xpath "//label[text()='Privacy assessment result']/following::span[text()[contains(.,'Privacy assessment information, including the meaning of the Privacy assessment result, can be found')]]"
        And I should see "Privacy assessment information, including the meaning of the Privacy assessment result, can be found here."
        And I should see an element with xpath "//label[text()='Privacy assessment result']/following::a[text()='here']"

    @fixture.dataset_with_schema::name=package-with-csv-res::owner_org=test-organisation
    @fixture.create_resource_for_dataset_with_params::package_id=package-with-csv-res
    Scenario: API viewing of new resource metadata field `Privacy assessment result`
        Given "TestOrgEditor" as the persona
        When I log in
        Then I visit "api/action/package_show?id=package-with-csv-res"
        And I should see an element with xpath "//body/*[contains(text(), '"privacy_assessment_result":')]"

    @fixture.dataset_with_schema::name=package-with-csv-res::owner_org=test-organisation
    @fixture.create_resource_for_dataset_with_params::package_id=package-with-csv-res
    Scenario: Sysadmin can edit 'Privacy assessment result' in GUI
        Given "SysAdmin" as the persona
        When I log in
        Then I visit "api/action/package_show?id=package-with-csv-res"
        And I should see an element with xpath "//body/*[contains(text(), '"privacy_assessment_result":')]"

        Then I go to dataset "package-with-csv-res"
        Then I press the element with xpath "//li[@class="resource-item"]/a"
        Then I press the element with xpath "//a[text()[contains(.,'Manage')]]"
        And I should see an element with xpath "//input[@name='privacy_assessment_result']"

        Then I fill in "privacy_assessment_result" with "New privacy_assessment_result"
        And I press the element with xpath "//button[@name="save"]"
        Then I should see "New privacy_assessment_result"

    @fixture.dataset_with_schema::name=package-with-new-privacy-assessment::owner_org=test-organisation::author_email=test@gmail.com
    @fixture.create_resource_for_dataset_with_params::package_id=package-with-new-privacy-assessment::name=pending-assessment-resource::request_privacy_assessment=YES
    Scenario: Email to dataset contact when result of requested privacy assessment is posted
        Given "SysAdmin" as the persona
        When I log in
        And I go to dataset "package-with-new-privacy-assessment"
        And I press the element with xpath "//li[@class="resource-item"]/a"
        And I press the element with xpath "//a[text()[contains(.,'Manage')]]"
        And I fill in "privacy_assessment_result" with "New privacy_assessment_result"
        And I press the element with xpath "//button[@name="save"]"
        And I trigger notification about updated privacy assessment results
        Then I should receive an email at "test@gmail.com" containing "A privacy risk assessment was requested for a resource. The result of that assessment has been published to data.qld.gov.au."
        And I should receive an email at "test@gmail.com" containing "Resource/s"
        And I should receive an email at "test@gmail.com" containing "Refer to ‘https://www.data.qld.gov.au/article/standards-and-guidance/publishing-guides-standards/open-data-portal-publishing-guide’ for assistance or contact opendata@qld.gov.au."
        And I should receive an email at "test@gmail.com" containing "Do not reply to this email."
        When I click the resource link in the email I received at "test@gmail.com"
        Then I should see "New privacy_assessment_result"
