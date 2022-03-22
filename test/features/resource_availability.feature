@resource_visibility
@OpenData
Feature: Re-identification risk governance acknowledgement or Resource visibility


    Scenario: Sysadmin creates dataset with Contains de-identified data is YES
        Given "SysAdmin" as the persona
        When I log in
        And I go to "/dataset/new"
        Then I fill in "title" with "Contains de-identified data - YES"
        Then I fill in "notes" with "notes"
        Then I execute the script "document.getElementById('field-organizations').value=jQuery('#field-organizations option').filter(function () { return $(this).html() == 'Test Organisation'; }).attr('value')"
        Then I select "False" from "private"
        Then I fill in "version" with "1"
        Then I fill in "author_email" with "test@test.com"
        Then I select "YES" from "de_identified_data"
        And I press the element with xpath "//form[contains(@class, 'dataset-form')]//button[contains(@class, 'btn-primary')]"
        And I wait for 10 seconds
        Then I execute the script "document.getElementById('field-image-url').value='https://example.com'"
        And I fill in "name" with "res1"
        And I select "HTML" from "format"
        And I fill in "description" with "description"
        And I fill in "size" with "1024"
        And I select "Resource NOT visible/Pending acknowledgement" from "resource_visibility"
        And I press the element with xpath "//button[@value='go-metadata']"
        And I wait for 10 seconds
        Then I should see "Data and Resources"


    Scenario: Sysadmin creates dataset with Contains de-identified data is NO
        Given "SysAdmin" as the persona
        When I log in
        And I go to "/dataset/new"
        Then I fill in "title" with "Contains de-identified data - NO"
        Then I fill in "notes" with "notes"
        Then I execute the script "document.getElementById('field-organizations').value=jQuery('#field-organizations option').filter(function () { return $(this).html() == 'Test Organisation'; }).attr('value')"
        Then I select "False" from "private"
        Then I fill in "version" with "1"
        Then I fill in "author_email" with "test@test.com"
        Then I select "NO" from "de_identified_data"
        And I press the element with xpath "//form[contains(@class, 'dataset-form')]//button[contains(@class, 'btn-primary')]"
        And I wait for 10 seconds
        Then I execute the script "document.getElementById('field-image-url').value='https://example.com'"
        And I fill in "name" with "res1"
        And I select "HTML" from "format"
        And I fill in "description" with "description"
        And I fill in "size" with "1024"
        And I select "Resource NOT visible/Pending acknowledgement" from "resource_visibility"
        And I press the element with xpath "//button[@value='go-metadata']"
        And I wait for 10 seconds
        Then I should see "Data and Resources"


    Scenario Outline: When a user creates a resource for a dataset with Contains de-identified data is YES, re-identification risks must be assessed and data can be hidden from the public.
        Given "<User>" as the persona
        When I log in

        ###
        # Create resource that available for non-logged in user.
        ###
        And I go to "/dataset/new_resource/contains-de-identified-data-yes"

        # Check field visibility, xpath element start with 1.
        Then I should see an element with id "field-resource_visibility"
        And I should see an element with xpath "//select[@id='field-resource_visibility']/option[2][@disabled]"

        # Create the resource, with error.
        Then I execute the script "document.getElementById('field-image-url').value='https://example.com'"
        And I fill in "name" with "resource created by <User> and is available"
        And I select "HTML" from "format"
        And I fill in "description" with "description"
        And I fill in "size" with "1024"
        And I press the element with xpath "//form[contains(@class, 'resource-form')]//button[contains(@class, 'btn-primary')]"
        And I wait for 10 seconds
        Then I should see "This dataset has been recorded as containing de-identified data."

        # Create the resource, with success.
        When I select "Appropriate steps have been taken to minimise personal information re-identification risk prior to publishing" from "resource_visibility"
        And I press the element with xpath "//form[contains(@class, 'resource-form')]//button[contains(@class, 'btn-primary')]"
        And I wait for 10 seconds
        Then I should see "resource created by <User> and is available"
        When I press the element with xpath "//a[@title='resource created by <User> and is available']"
        Then I should see "Re-identification risk governance acknowledgement/Resource visibility"

        ###
        # Create resource that NOT available for non-logged in user.
        ###
        And I go to "/dataset/new_resource/contains-de-identified-data-yes"

        Then I execute the script "document.getElementById('field-image-url').value='https://example.com'"
        And I fill in "name" with "resource created by <User> and is NOT available"
        And I select "HTML" from "format"
        And I fill in "description" with "description"
        And I fill in "size" with "1024"
        And I select "Resource NOT visible/Pending acknowledgement" from "resource_visibility"
        And I press the element with xpath "//form[contains(@class, 'resource-form')]//button[contains(@class, 'btn-primary')]"
        And I wait for 10 seconds
        Then I should see "resource created by <User> and is NOT available"

        # Verify the result as non-logged in user.
        Given "Unauthenticated" as the persona
        And I go to "/dataset/contains-de-identified-data-yes"
        Then I should see "resource created by <User> and is available"
        Then I should not see "resource created by <User> and is NOT available"

        Examples: Users
            | User          |
            | SysAdmin      |
            | TestOrgAdmin  |
            | TestOrgEditor |


    Scenario Outline: When a user creates a resource for a dataset with Contains de-identified data is NO, re-identification risks do not need to be assessed, but data can still be hidden from the public.
        Given "<User>" as the persona
        When I log in

        ###
        # Create resource that available for non-logged in user.
        ###
        And I go to "/dataset/new_resource/contains-de-identified-data-no"

        # Check field visibility, xpath element start with 1.
        Then I should see an element with id "field-resource_visibility"
        And I should see an element with xpath "//select[@id='field-resource_visibility']/option[3][@disabled]"

        # Create the resource, with success.
        Then I execute the script "document.getElementById('field-image-url').value='https://example.com'"
        And I fill in "name" with "resource created by <User> and is available"
        And I select "HTML" from "format"
        And I fill in "description" with "description"
        And I fill in "size" with "1024"
        And I select "Resource visible and re-identification risk governance acknowledgement not required" from "resource_visibility"
        And I press the element with xpath "//form[contains(@class, 'resource-form')]//button[contains(@class, 'btn-primary')]"
        And I wait for 10 seconds
        Then I should see "resource created by <User> and is available"

        ###
        # Create resource that available for non-logged in user with resource_visibility blank.
        ###
        And I go to "/dataset/new_resource/contains-de-identified-data-no"

        # Create the resource, with success.
        Then I execute the script "document.getElementById('field-image-url').value='https://example.com'"
        And I fill in "name" with "resource created by <User> and is available with blank resource_visibility"
        And I select "HTML" from "format"
        And I fill in "description" with "description"
        And I fill in "size" with "1024"
        And I press the element with xpath "//form[contains(@class, 'resource-form')]//button[contains(@class, 'btn-primary')]"
        And I wait for 10 seconds
        Then I should see "resource created by <User> and is available with blank resource_visibility"

        ###
        # Create resource that NOT available for non-logged in user.
        ###
        And I go to "/dataset/new_resource/contains-de-identified-data-no"

        Then I execute the script "document.getElementById('field-image-url').value='https://example.com'"
        And I fill in "name" with "resource created by <User> and is NOT available"
        And I select "HTML" from "format"
        And I fill in "description" with "description"
        And I fill in "size" with "1024"
        And I select "Resource NOT visible/Pending acknowledgement" from "resource_visibility"
        And I press the element with xpath "//form[contains(@class, 'resource-form')]//button[contains(@class, 'btn-primary')]"
        And I wait for 10 seconds
        Then I should see "resource created by <User> and is NOT available"

        # Verify the result as non-logged in user.
        Given "Unauthenticated" as the persona
        When I go to "/dataset/contains-de-identified-data-no"
        Then I should see "resource created by <User> and is available"
        And I should see "resource created by <User> and is available with blank resource_visibility"
        And I should not see "resource created by <User> and is NOT available"
        Then I press the element with xpath "//a[@title='resource created by <User> and is available']"
        And I should not see "Re-identification risk governance acknowledgement/Resource visibility"

        Examples: Users
            | User          |
            | SysAdmin      |
            | TestOrgAdmin  |
            | TestOrgEditor |
