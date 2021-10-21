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
        Then I press "save"
        And I wait for 10 seconds
        Then I execute the script "document.getElementById('field-image-url').value='http://ckanext-data-qld.docker.amazee.io/'"
        Then I fill in "name" with "res1"
        Then I fill in "description" with "description"
        Then I fill in "size" with "1024"
        Then I select "Resource NOT visible/Pending acknowledgement" from "resource_visibility"
        Then I press the element with xpath "//button[@value='go-metadata']"
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
        Then I press "save"
        And I wait for 10 seconds
        Then I execute the script "document.getElementById('field-image-url').value='http://ckanext-data-qld.docker.amazee.io/'"
        Then I fill in "name" with "res1"
        Then I fill in "description" with "description"
        Then I fill in "size" with "1024"
        Then I select "Resource NOT visible/Pending acknowledgement" from "resource_visibility"
        Then I press the element with xpath "//button[@value='go-metadata']"
        And I wait for 10 seconds
        Then I should see "Data and Resources"


    Scenario Outline: User creates resource for a dataset with Contains de-identified data is YES
        Given "<User>" as the persona
        When I log in

        ###
        # Create resource that available for non-logged in user.
        ###
        And I go to "/dataset/new_resource/contains-de-identified-data-yes"

        # Check field visibility, xpath element start with 1.
        Then I should see an element with id "field-resource_visibility"
        Then I should see an element with xpath "//select[@id='field-resource_visibility']/option[2][@disabled]"

        # Create the resource, with error.
        Then I execute the script "document.getElementById('field-image-url').value='http://ckanext-data-qld.docker.amazee.io/'"
        Then I fill in "name" with "resource created by <User> and is available"
        Then I fill in "description" with "description"
        Then I fill in "size" with "1024"
        Then I press "save"
        And I wait for 10 seconds
        Then I should see "This dataset has been recorded as containing de-identified data."

        # Create the resource, with success.
        Then I select "Appropriate steps have been taken to minimise personal information re-identification risk prior to publishing" from "resource_visibility"
        Then I press "save"
        And I wait for 10 seconds
        Then I should see "resource created by <User> and is available"

        ###
        # Create resource that NOT available for non-logged in user.
        ###
        And I go to "/dataset/new_resource/contains-de-identified-data-yes"

        Then I execute the script "document.getElementById('field-image-url').value='http://ckanext-data-qld.docker.amazee.io/'"
        Then I fill in "name" with "resource created by <User> and is NOT available"
        Then I fill in "description" with "description"
        Then I fill in "size" with "1024"
        Then I select "Resource NOT visible/Pending acknowledgement" from "resource_visibility"
        Then I press "save"
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


    Scenario Outline: User creates resource for a dataset with Contains de-identified data is NO
        Given "<User>" as the persona
        When I log in

        ###
        # Create resource that available for non-logged in user.
        ###
        And I go to "/dataset/new_resource/contains-de-identified-data-no"

        # Check field visibility, xpath element start with 1.
        Then I should see an element with id "field-resource_visibility"
        Then I should see an element with xpath "//select[@id='field-resource_visibility']/option[3][@disabled]"

        # Create the resource, with success.
        Then I execute the script "document.getElementById('field-image-url').value='http://ckanext-data-qld.docker.amazee.io/'"
        Then I fill in "name" with "resource created by <User> and is available"
        Then I fill in "description" with "description"
        Then I fill in "size" with "1024"
        Then I select "Resource visible and re-identification risk governance acknowledgement not required" from "resource_visibility"
        Then I press "save"
        And I wait for 10 seconds
        Then I should see "resource created by <User> and is available"

        ###
        # Create resource that available for non-logged in user with resource_visibility blank.
        ###
        And I go to "/dataset/new_resource/contains-de-identified-data-no"

        # Create the resource, with success.
        Then I execute the script "document.getElementById('field-image-url').value='http://ckanext-data-qld.docker.amazee.io/'"
        Then I fill in "name" with "resource created by <User> and is available with blank resource_visibility"
        Then I fill in "description" with "description"
        Then I fill in "size" with "1024"
        Then I press "save"
        And I wait for 10 seconds
        Then I should see "resource created by <User> and is available with blank resource_visibility"

        ###
        # Create resource that NOT available for non-logged in user.
        ###
        And I go to "/dataset/new_resource/contains-de-identified-data-no"

        Then I execute the script "document.getElementById('field-image-url').value='http://ckanext-data-qld.docker.amazee.io/'"
        Then I fill in "name" with "resource created by <User> and is NOT available"
        Then I fill in "description" with "description"
        Then I fill in "size" with "1024"
        Then I select "Resource NOT visible/Pending acknowledgement" from "resource_visibility"
        Then I press "save"
        And I wait for 10 seconds
        Then I should see "resource created by <User> and is NOT available"

        # Verify the result as non-logged in user.
        Given "Unauthenticated" as the persona
        And I go to "/dataset/contains-de-identified-data-no"
        Then I should see "resource created by <User> and is available"
        Then I should see "resource created by <User> and is available with blank resource_visibility"
        Then I should not see "resource created by <User> and is NOT available"

        Examples: Users
            | User          |
            | SysAdmin      |
            | TestOrgAdmin  |
            | TestOrgEditor |


    Scenario Outline: An editor, admin or sysadmin user views a dataset resource additional info
        Given "<User>" as the persona
        When I log in

        And I go to "/dataset/contains-de-identified-data-yes"
        Then I press the element with xpath "//a[@title='resource created by SysAdmin and is available']"
        Then I should see "Re-identification risk governance acknowledgement/Resource visibility"

        Examples: Users
            | User          |
            | SysAdmin      |
            | TestOrgAdmin  |
            | TestOrgEditor |


    Scenario: A Member views a dataset resource additional info
        Given "TestOrgMember" as the persona
        When I log in

        And I go to "/dataset/contains-de-identified-data-yes"
        Then I press the element with xpath "//a[@title='resource created by SysAdmin and is available']"
        Then I should not see "Re-identification risk governance acknowledgement/Resource visibility"

    Scenario: A general user views a dataset resource additional info
        Given "Unauthenticated" as the persona

        And I go to "/dataset/contains-de-identified-data-yes"
        Then I press the element with xpath "//a[@title='resource created by SysAdmin and is available']"
        Then I should not see "Re-identification risk governance acknowledgement/Resource visibility"


    Scenario: Clean up
        Given "SysAdmin" as the persona
        When I log in
        And I go to "/dataset/edit/contains-de-identified-data-yes"
        Then I press the element with xpath "//a[@data-module='confirm-action']"
        And I wait for 5 seconds
        When I type "it should be longer than 10 character" to "deletion_reason"
        Then I press the element with xpath "//div[@class='modal-footer']//button[@class='btn btn-primary']"
        And I wait for 10 seconds

        And I go to "/dataset/edit/contains-de-identified-data-no"
        Then I press the element with xpath "//a[@data-module='confirm-action']"
        And I wait for 5 seconds
        When I type "it should be longer than 10 character" to "deletion_reason"
        Then I press the element with xpath "//div[@class='modal-footer']//button[@class='btn btn-primary']"
        And I wait for 10 seconds

        When I go to "/ckan-admin/trash"
        Then I press the element with xpath "//button[@name='purge-packages']"
