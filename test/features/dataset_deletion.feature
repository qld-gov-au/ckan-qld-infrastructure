@dataset_deletion
Feature: Dataset deletion

    @OpenData
    Scenario: Sysadmin creates a dataset
        Given "SysAdmin" as the persona
        When I log in
        And I go to "/dataset/new"
        Then I fill in "title" with "Dataset deletion"
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

    @Publications
    Scenario: Sysadmin creates a dataset
        Given "SysAdmin" as the persona
        When I log in
        And I go to "/dataset/new"
        Then I fill in "title" with "Dataset deletion"
        Then I fill in "notes" with "notes"
        Then I execute the script "document.getElementById('field-organizations').value=jQuery('#field-organizations option').filter(function () { return $(this).html() == 'Test Organisation'; }).attr('value')"
        Then I select "False" from "private"
        Then I fill in "version" with "1"
        Then I fill in "author_email" with "test@test.com"
        Then I press "save"
        And I wait for 10 seconds
        Then I execute the script "document.getElementById('field-image-url').value='http://ckanext-data-qld.docker.amazee.io/'"
        Then I fill in "name" with "res1"
        Then I fill in "description" with "description"
        Then I fill in "size" with "1024"
        Then I press the element with xpath "//button[@value='go-metadata']"
        And I wait for 10 seconds
        Then I should see "Data and Resources"

    Scenario: Sysadmin deletes a dataset
        Given "SysAdmin" as the persona
        When I log in
        And I go to "/dataset/edit/dataset-deletion"
        Then I should see an element with xpath "//a[@data-module='confirm-action']"
        Then I press the element with xpath "//a[@data-module='confirm-action']"
        And I wait for 5 seconds
        Then I should see "Briefly describe the reason for deleting this dataset"
        Then I should see an element with xpath "//div[@class='modal-footer']//button[@class='btn btn-primary' and @disabled='disabled']"
        When I type "it should be longer than 10 character" to "deletion_reason"
        Then I should not see an element with xpath "//div[@class='modal-footer']//button[@class='btn btn-primary' and @disabled='disabled']"
        Then I press the element with xpath "//div[@class='modal-footer']//button[@class='btn btn-primary']"
        And I wait for 10 seconds
        Then I should not see "Dataset deletion"
        And I go to "/ckan-admin/trash"
        Then I should see "Dataset deletion"
        Then I press the element with xpath "//button[@name='purge-packages']"
