@resource_visibility
@OpenData
Feature: Re-identification risk governance acknowledgement or Resource visibility

    @fixture.dataset_with_schema::name=random_package::owner_org=test-organisation::de_identified_data=NO
    @fixture.create_resource_for_dataset_with_params::package_id=random_package::name=invisible-resource::resource_visible=FALSE
    Scenario: resource with resource_visible=False must be visible for org editor, org admin
        Given "TestOrgEditor" as the persona
        When I log in
        Then I go to dataset "random_package"
        And I should see "invisible-resource"

    @fixture.dataset_with_schema::name=random_package::owner_org=test-organisation::de_identified_data=NO
    @fixture.create_resource_for_dataset_with_params::package_id=random_package::name=invisible-resource::resource_visible=FALSE
    Scenario: resource with resource_visible=False mustnt be visible for regular user, org editor/admin from different org
        Given "CKANUser" as the persona
        When I log in
        Then I go to dataset "random_package"
        And I should not see "invisible-resource"

    @fixture.dataset_with_schema::name=random_package::owner_org=test-organisation::de_identified_data=NO
    @fixture.create_resource_for_dataset_with_params::package_id=random_package::name=visible-resource::request_privacy_assessment=YES::governance_acknowledgement=YES::resource_visible=TRUE
    Scenario: Resource visible, governance_acknowledgement & request_privacy_assessment & not de_identified_data
        Given "CKANUser" as the persona
        When I log in
        Then I go to dataset "random_package"
        And I should see "visible-resource"

    @fixture.dataset_with_schema::name=random_package::owner_org=test-organisation::de_identified_data=YES
    @fixture.create_resource_for_dataset_with_params::package_id=random_package::name=visible-resource::request_privacy_assessment=NO::governance_acknowledgement=YES::resource_visible=TRUE
    Scenario: Resource visible, governance_acknowledgement & not request_privacy_assessment & de_identified_data
        Given "CKANUser" as the persona
        When I log in
        Then I go to dataset "random_package"
        And I should see "visible-resource"

    @fixture.dataset_with_schema::name=random_package::owner_org=test-organisation::de_identified_data=YES
    @fixture.create_resource_for_dataset_with_params::package_id=random_package::name=visible-resource::request_privacy_assessment=NO::governance_acknowledgement=YES::resource_visible=TRUE
    Scenario: Resource visible for Unauthenticated, governance_acknowledgement & not request_privacy_assessment & de_identified_data
        Given "Unauthenticated" as the persona
        Then I go to dataset "random_package"
        And I should see "visible-resource"

    @fixture.dataset_with_schema::name=random_package::owner_org=test-organisation::de_identified_data=YES
    @fixture.create_resource_for_dataset_with_params::package_id=random_package::name=invisible-resource::request_privacy_assessment=YES::governance_acknowledgement=NO::resource_visible=TRUE
    Scenario: Resource visible, not governance_acknowledgement & not request_privacy_assessment & de_identified_data
        Given "CKANUser" as the persona
        When I log in
        Then I go to dataset "random_package"
        And I should not see "invisible-resource"

    @fixture.dataset_with_schema::name=random_package::owner_org=test-organisation::de_identified_data=YES
    @fixture.create_resource_for_dataset_with_params::package_id=random_package::name=invisible-resource::request_privacy_assessment=YES::governance_acknowledgement=NO::resource_visible=TRUE
    Scenario: Resource not visible for Unauthenticated, not governance_acknowledgement & not request_privacy_assessment & de_identified_data
        Given "Unauthenticated" as the persona
        Then I go to dataset "random_package"
        And I should not see "invisible-resource"

    @fixture.dataset_with_schema::name=random_package::owner_org=test-organisation::de_identified_data=YES
    @fixture.create_resource_for_dataset_with_params::package_id=random_package::name=invisible-resource::request_privacy_assessment=YES::governance_acknowledgement=YES::resource_visible=TRUE
    Scenario: Resource visible, governance_acknowledgement & request_privacy_assessment & de_identified_data
        Given "CKANUser" as the persona
        When I log in
        Then I go to dataset "random_package"
        And I should not see "invisible-resource"

    @fixture.dataset_with_schema::name=random_package::owner_org=test-organisation::de_identified_data=NO
    @fixture.create_resource_for_dataset_with_params::package_id=random_package::name=invisible-resource::resource_visible=FALSE
    Scenario: update the invisible resource
        Given "TestOrgEditor" as the persona
        When I log in
        Then I go to dataset "random_package"
        And I click the link with text that contains "invisible-resource"
        And I click the link with text that contains "Manage"
        And I should not see an element with xpath "//label[@for="field-request_privacy_assessment"]//*[@class="control-required"]"
        And I should see an element with xpath "//select[@id="field-request_privacy_assessment"]//option[@value="" or @value="YES" or @value="NO"]"
        And I press the element with xpath "//button[text()='Update Resource']"
        And I should see an element with xpath "//th[text()='Request privacy assessment']/following-sibling::td[not(text())]"

    @fixture.dataset_with_schema::name=random_package::owner_org=test-organisation::de_identified_data=NO
    @fixture.create_resource_for_dataset_with_params::package_id=random_package::name=visible-resource::resource_visible=TRUE::governance_acknowledgement=NO
    Scenario: Unauthenticated user should see a visible resource when de-identified data is NO and Resource visibility is TRUE and Acknowledgement is NO
        Given "Unauthenticated" as the persona
        When I go to dataset "random_package"
        And I should see "visible-resource"
