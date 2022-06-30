Feature: Dataset APIs

    Scenario: Creative Commons BY-NC-SA 4.0 licence is an option for datasets
        Given "SysAdmin" as the persona
        When I log in
        And I edit the "warandpeace" dataset
        Then I should see an element with xpath "//option[@value='cc-by-nc-sa-4']"

    Scenario: As a publisher, I can view the change history of a dataset
        Given "TestOrgEditor" as the persona
        When I log in
        And I edit the "public-test-dataset" dataset
        And I fill in "author_email" with "admin@example.com"
        And I press the element with xpath "//form[contains(@class, 'dataset-form')]//button[contains(@class, 'btn-primary')]"
        And I press the element with xpath "//a[contains(@href, '/dataset/activity/') and contains(string(), 'Activity Stream')]"
        Then I should see "created the dataset"
        When I click the link with text that contains "View this version"
        Then I should see "You're currently viewing an old version of this dataset."
        When I go to dataset "public-test-dataset"
        And I press the element with xpath "//a[contains(@href, '/dataset/activity/') and contains(string(), 'Activity Stream')]"
        And I click the link with text that contains "Changes"
        Then I should see "View changes from"
        And I should see an element with xpath "//select[@name='old_id']"
        And I should see an element with xpath "//select[@name='new_id']"

    @Publications
    Scenario: As a user with publishing privileges, I can create a dataset
        Given "TestOrgEditor" as the persona
        When I log in
        And I visit "/dataset/new"
        And I fill in title with random text
        And I fill in "notes" with "Testing dataset creation"
        And I fill in "version" with "1.0"
        And I fill in "author_email" with "test@me.com"
        And I press "Add Data"
        And I press the element with xpath "//form[@id='resource-edit']//a[string() = 'Link']"
        And I fill in "name" with "Test"
        And I fill in "url" with "https://example.com"
        And I press the element with xpath "//button[contains(string(), 'Finish')]"
        Then I should see "Testing dataset creation"
