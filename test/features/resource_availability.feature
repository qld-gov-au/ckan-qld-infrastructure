@resource_visibility
@OpenData
Feature: Re-identification risk governance acknowledgement or Resource visibility

    Scenario: As a publisher, I can view hidden resources
        Given "TestOrgEditor" as the persona
        When I log in
        And I create a dataset and resource with key-value parameters "name=package-with-invisible-resource::notes=Package with invisible resource::de_identified_data=NO::private=False" and "name=invisible-resource::resource_visible=FALSE"
        Then I should see "invisible-resource"

        Given "CKANUser" as the persona
        When I log out
        And I log in
        And I go to dataset "package-with-invisible-resource"
        Then I should see "Package with invisible resource"
        And I should not see "invisible-resource"

    Scenario: As an unprivileged user, I cannot see resources with privacy assessment requested and risk governance completed 
        Given "TestOrgEditor" as the persona
        When I log in
        And I create a dataset and resource with key-value parameters "name=package-with-assessed-resource::notes=Package with assessed resource::de_identified_data=NO::private=False" and "name=resource-for-assessment::request_privacy_assessment=YES::governance_acknowledgement=YES::resource_visible=TRUE"
        Then I should see "resource-for-assessment"

        Given "CKANUser" as the persona
        When I log out
        And I log in
        And I go to dataset "package-with-assessed-resource"
        Then I should not see "resource-for-assessment"

    Scenario: As an unprivileged user, I can see de-identified resources marked as visible without a privacy assessment
        Given "TestOrgEditor" as the persona
        When I log in
        And I create a dataset and resource with key-value parameters "name=de-identified-package-with-unassessed-resource::de_identified_data=YES::private=False" and "name=visible-resource::request_privacy_assessment=NO::governance_acknowledgement=YES::resource_visible=TRUE"

        Given "CKANUser" as the persona
        When I log out
        And I log in
        And I go to dataset "de-identified-package-with-unassessed-resource"
        Then I should see "visible-resource"

        When I log out
        And I go to dataset "de-identified-package-with-unassessed-resource"
        Then I should see "visible-resource"

    Scenario: As an unprivileged user, I cannot see de-identified resources with an incomplete privacy assessment
        Given "TestOrgEditor" as the persona
        When I log in
        And I create a dataset and resource with key-value parameters "name=de-identified-package-with-partially-assessed-resource::de_identified_data=YES" and "name=invisible-resource::request_privacy_assessment=YES::governance_acknowledgement=NO::resource_visible=TRUE"
        Then I should see "invisible-resource"

        Given "CKANUser" as the persona
        When I log out
        And I log in
        And I go to dataset "de-identified-package-with-partially-assessed-resource"
        Then I should not see "invisible-resource"

        When I log out
        And I go to dataset "de-identified-package-with-partially-assessed-resource"
        Then I should not see "invisible-resource"

    Scenario: As an unprivileged user, I cannot see de-identified resources
        Given "TestOrgEditor" as the persona
        When I log in
        And I create a dataset and resource with key-value parameters "name=de-identified-package-with-assessed-resource::de_identified_data=YES" and "name=invisible-resource::request_privacy_assessment=YES::governance_acknowledgement=YES::resource_visible=TRUE"
        Then I should see "invisible-resource"

        Given "CKANUser" as the persona
        When I log out
        And I log in
        And I go to dataset "random_package"
        Then I should not see "invisible-resource"

    Scenario: As a publisher, when I edit a resource, I can set its visibility
        Given "TestOrgEditor" as the persona
        When I log in
        And I create a dataset and resource with key-value parameters "de_identified_data=NO" and "name=invisible-resource::resource_visible=FALSE"
        And I press "invisible-resource"
        And I press "Manage"
        Then I should not see an element with xpath "//label[@for="field-request_privacy_assessment"]//*[@class="control-required"]"
        And I should see an element with xpath "//select[@id="field-request_privacy_assessment"]//option[@value="" or @value="YES" or @value="NO"]"

        When I press the element with xpath "//button[string()='Update Resource']"
        Then I should see an element with xpath "//th[string()='Request privacy assessment']/following-sibling::td[not(string())]"

    Scenario: As an anonymous user, I can see resources without de-identified data
        Given "TestOrgEditor" as the persona
        When I log in
        And I create a dataset and resource with key-value parameters "name=package-without-de-identified-data::de_identified_data=NO::private=False" and "name=visible-resource::governance_acknowledgement=NO::resource_visible=TRUE"

        When I log out
        And I go to dataset "package-without-de-identified-data"
        Then I should see "visible-resource"
