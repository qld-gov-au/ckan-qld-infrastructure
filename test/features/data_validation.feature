@config
@OpenData
Feature: Data Validation

    Scenario Outline: As a sysadmin, admin and editor user of the dataset organisation I can see the 'JSON' button
       Given "<User>" as the persona
        When I log in
        And I open the new resource form for dataset "public-test-dataset"
        Then I should see an element with xpath "//textarea[@name='schema_json']"

        Examples: Users
        | User              |
        | SysAdmin          |
        | TestOrgAdmin      |
        | TestOrgEditor     |

     Scenario: As any user, I can view the 'Data Schema' link in the 'Additional Info' table of the resource read-view page
       Given "SysAdmin" as the persona
        When I log in
        And I visit "dataset/new"
        And I fill in default dataset fields
        And I press "Add Data"
        And I fill in default resource fields
        And I fill in link resource fields
        And I execute the script "document.getElementById('field-schema-upload').parentNode.parentNode.setAttribute('style', '')"
        And I attach the file "test-resource_schemea.json" to "schema_upload"
        And I press "Finish"
        And I wait for 1 seconds
        And I press "Test Resource"
        And I press "View Schema File"
        Then I should see "Measure of the oblique fractal impedance at noon"
