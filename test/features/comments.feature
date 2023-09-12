@comments
@OpenData
Feature: Comments

    @unauthenticated
    Scenario: The Add Comment form should not display for a non-logged-in user - instead they see a 'Login to comment' button
        Given "Unauthenticated" as the persona
        When I go to dataset "public-test-dataset" comments
        Then I should see "Login to comment" within 1 seconds
        And I should not see the add comment form

    Scenario: Logged-in users see the add comment form
        Given "CKANUser" as the persona
        When I log in
        And I go to dataset "public-test-dataset" comments
        Then I should see the add comment form

    @comment-add
    Scenario: When a logged-in user submits a comment on a Dataset the comment should display within 10 seconds
        Given "TestOrgEditor" as the persona
        When I log in
        And I create a dataset with key-value parameters "notes=Add Dataset Comment"
        And I go to dataset "$last_generated_name" comments
        Then I should see the add comment form
        When I submit a comment with subject "Test subject" and comment "This is a test comment"
        Then I should see "This is a test comment" within 10 seconds
        And I should see an element with xpath "//div[contains(@class, 'comment-wrapper') and contains(string(), 'This is a test comment')]"
        When I go to dataset "$last_generated_name"
        Then I should see an element with xpath "//span[contains(@class, 'badge') and contains(string(), '1')]"

    @comment-add @datarequest
    Scenario: When a logged-in user submits a comment on a Data Request the comment should then be visible on the Comments tab of the Data Request
        Given "CKANUser" as the persona
        When I log in
        And I create a datarequest
        And I go to data request "$last_generated_title" comments
        Then I should see an element with xpath "//h3[contains(string(), 'Add a comment')]"
        When I submit a comment with subject "Test subject" and comment "This is a test comment"
        Then I should see "This is a test comment" within 10 seconds

    @comment-add @datarequest @email
    Scenario: When a logged-in user submits a comment on a Data Request the email should contain title and comment
        Given "CKANUser" as the persona
        When I log in
        And I create a datarequest
        And I go to data request "$last_generated_title" comments
        Then I should see an element with xpath "//h3[contains(string(), 'Add a comment')]"
        When I submit a comment with subject "Testing Data Request comment" and comment "This is a test data request comment"
        And I wait for 5 seconds
        Then I should receive a base64 email at "dr_admin@localhost" containing both "Data request subject: Test Title" and "Comment: This is a test data request comment"

    @comment-add @comment-profane
    Scenario: When a logged-in user submits a comment containing profanity on a Dataset they should receive an error message and the comment will not appear
        Given "TestOrgEditor" as the persona
        When I log in
        And I create a dataset with key-value parameters "notes=Profane Dataset Comment"
        And I go to dataset "$last_generated_name" comments
        Then I should see the add comment form
        When I submit a comment with subject "Test subject" and comment "He had sheep, and oxen, and he asses, and menservants, and maidservants, and she asses, and camels."
        Then I should see "Comment blocked due to profanity" within 5 seconds

    @comment-add @comment-profane
    Scenario: When a logged-in user submits a comment containing whitelisted profanity on a Dataset the comment should display within 10 seconds
        Given "TestOrgEditor" as the persona
        When I log in
        And I create a dataset with key-value parameters "notes=Whitelisted Dataset Comment"
        And I go to dataset "$last_generated_name" comments
        Then I should see the add comment form
        When I submit a comment with subject "Test subject" and comment "sex"
        Then I should see "sex" within 10 seconds

    @comment-add @comment-profane @datarequest
    Scenario: When a logged-in user submits a comment containing profanity on a Data Request they should receive an error message and the comment will not appear
        Given "CKANUser" as the persona
        When I log in
        And I create a datarequest
        And I go to data request "$last_generated_title" comments
        Then I should see an element with xpath "//h3[contains(string(), 'Add a comment')]"
        When I submit a comment with subject "Test subject" and comment "He had sheep, and oxen, and he asses, and menservants, and maidservants, and she asses, and camels."
        Then I should see "Comment blocked due to profanity" within 5 seconds

    @comment-report @email
    Scenario: When a logged-in user reports a comment on a Dataset the comment should be marked as reported and an email sent to the admins of the organisation
        Given "TestOrgEditor" as the persona
        When I log in
        And I create a dataset with key-value parameters "notes=Report Dataset Comment"
        And I go to dataset "$last_generated_name" comments
        Then I should see the add comment form
        When I submit a comment with subject "Testing flags" and comment "Test"
        And I press the element with xpath "//a[contains(@class, 'flag-comment')][1]"
        And I confirm the dialog containing "comment has been flagged as inappropriate" if present
        And I wait for 5 seconds
        And I go to dataset "$last_generated_name" comments
        Then I should see "Reported"
        And I should receive a base64 email at "test_org_admin@localhost" containing "This comment has been flagged as inappropriate by a user"

    @comment-report @datarequest @email
    Scenario: When a logged-in user reports a comment on a Data Request the comment should be marked as reported and an email notification sent to the organisation admins
        Given "CKANUser" as the persona
        When I log in
        And I create a datarequest
        And I go to data request "$last_generated_title" comments
        And I submit a comment with subject "Test reporting" and comment "Testing comment reporting"
        Then I should see "Testing comment reporting" within 10 seconds

        When I press the element with xpath "//a[contains(@class, 'flag-comment')][1]"
        And I confirm the dialog containing "comment has been flagged as inappropriate" if present
        And I wait for 5 seconds
        And I go to data request "$last_generated_title" comments
        Then I should see "Reported"
        And I should receive a base64 email at "dr_admin@localhost" containing "This comment has been flagged as inappropriate by a user"

    @comment-reply
    Scenario: When a logged-in user submits a reply comment on a Dataset, the comment should display within 10 seconds
        Given "TestOrgEditor" as the persona
        When I log in
        And I create a dataset with key-value parameters "notes=Reply to Dataset Comment"
        And I go to dataset "$last_generated_name" comments
        Then I should see the add comment form
        When I submit a comment with subject "Testing reply" and comment "Test"
        And I submit a reply with comment "This is a reply"
        Then I should see "This is a reply" within 10 seconds

    @comment-delete
    Scenario: When an admin visits a dataset belonging to their organisation, they can delete a comment and should see deletion text for the user responsible.
        Given "TestOrgAdmin" as the persona
        When I log in
        And I create a dataset with key-value parameters "notes=Admin Delete Dataset Comment"
        And I go to dataset "$last_generated_name" comments
        Then I should see the add comment form
        When I submit a comment with subject "Testing deletion" and comment "Test"
        And I press the element with xpath "//a[@title='Delete comment']"
        And I confirm the dialog containing "Are you sure you want to delete this comment?" if present
        Then I should not see "This comment was deleted." within 2 seconds
        And I should see "Comment deleted by Test Admin." within 2 seconds

    @comment-delete @datarequest
    Scenario: When an admin visits a data request belonging to their organisation, they can delete a comment and should see deletion text for the user responsible.
        Given "DataRequestOrgAdmin" as the persona
        When I log in
        And I create a datarequest
        And I go to data request "$last_generated_title" comments
        When I submit a comment with subject "Testing deletion" and comment "Test"
        And I press the element with xpath "//a[@title='Delete comment']"
        And I confirm the dialog containing "Are you sure you want to delete this comment?" if present
        Then I should not see "This comment was deleted." within 2 seconds
        And I should see "Comment deleted by Data Request Admin." within 2 seconds

    @comment-tab
    @unauthenticated
    Scenario: Non-logged in users should not see comment form in dataset tab
        Given "Unauthenticated" as the persona
        When I go to dataset "public-test-dataset"
        Then I should not see an element with id "comment_form"

    @comment-tab
    Scenario: Logged in users should not see comment form in dataset tab
        Given "CKANUser" as the persona
        When I log in
        And I go to dataset "public-test-dataset"
        Then I should not see an element with id "comment_form"

    @comment-tab
    @unauthenticated
    Scenario: Users should see comment tab on dataset
        Given "Unauthenticated" as the persona
        When I go to dataset "public-test-dataset"
        Then I should see an element with xpath "//a[contains(string(), 'Comments')]"
