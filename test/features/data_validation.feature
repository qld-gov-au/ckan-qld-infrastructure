@config
@OpenData
Feature: Data Validation

    Scenario Outline: As a sysadmin, admin and editor user of the dataset organisation I cannot see the '</> JSON' button
       Given "<User>" as the persona
        When I log in
        And I visit "dataset/new_resource/annakarenina"
        And I should not see an element with xpath "//a[contains(string(), '</> JSON')]"

        Examples: Users
        | User              |
        | SysAdmin          |
        | TestOrgAdmin      |
        | TestOrgEditor     |


     Scenario: As any user, I can view the 'Data Schema' link in the 'Additional Info' table of the resource read-view page
       Given "SysAdmin" as the persona
        When I log in
        And I visit "dataset/new"
        When I fill in title with random text
        When I fill in "notes" with "Description"
        When I fill in "version" with "1.0"
        When I fill in "author_email" with "test@me.com"
        Then I select "NO" from "de_identified_data"
        When I press "Add Data"
        And I execute the script "document.getElementById('field-image-url').value='https://example.com'"
        And I fill in "name" with "Test Resource"
        And I execute the script "document.getElementById('field-format').value='HTML'"
        And I fill in "description" with "Test Resource Description"
        And I fill in "size" with "1mb"
        And I execute the script "document.getElementById('field-schema-upload').parentNode.parentNode.setAttribute('style', '')"
        And I attach the file "test-resource_schemea.json" to "schema_upload"
        And I press "Finish"
        When I wait for 1 seconds
        And I click the link with text that contains "Test Resource"
        And I click the link with text that contains "View Schema File"
        Then I should see "Measure of the oblique fractal impedance at noon"
