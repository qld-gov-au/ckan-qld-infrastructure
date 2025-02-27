@resources
Feature: Resource UI

    Scenario Outline: Link resource should create a link to its URL
        Given "SysAdmin" as the persona
        When I log in
        And I open the new resource form for dataset "test-dataset"
        And I create a resource with key-value parameters "name=<name>::url=<url>"
        And I press the element with xpath "//a[(contains(@title, '<name>') or contains(@aria-label, 'Navigate to resource: <name>')) and contains(string(), '<name>')]"
        Then I should see "<url>"

        Examples:
        | name | url |
        | Good link | http://www.qld.gov.au |
        | Good IP address | http://1.2.3.4 |
        | Domain starting with numbers | http://1.2.3.4.example.com |
        # chrome url type input treats it as invalid one
        # | Domain ending with numbers | http://example.com.1.2.3.4 |
        | Domain ending with private | http://example.com.private |

    Scenario: As a publisher, when I create a resource with a long name, it should be preserved
        Given "TestOrgEditor" as the persona
        When I log in
        And I create a dataset and resource with key-value parameters "title=More than 30 characters aaaaaaaaaaaa" and "name=More than 30 characters bbbbbbbbbbbb"
        # Breadcrumbs should not be truncated
        Then I should see an element with xpath "//ol[contains(@class, 'breadcrumb')]//a[contains(string(), 'More than 30 characters aaaaaaaaaaaa')]"
        And I should see "More than 30 characters bbbbbbbbbbbb"
        When I press "More than 30 characters bbbbbbbbbbbb"
        Then I should see an element with xpath "//ol[contains(@class, 'breadcrumb')]//a[contains(string(), 'More than 30 characters aaaaaaaaaaaa')]"
        And I should see an element with xpath "//ol[contains(@class, 'breadcrumb')]//a[contains(string(), 'More than 30 characters bbbbbbbbbbbb')]"
        # Sidebar resource nav truncates but preserves full name in a tooltip
        And I should see an element with xpath "//li[contains(@class, 'nav-item')]//a[contains(string(), 'More than 30') and contains(string(), '...') and @title = 'More than 30 characters bbbbbbbbbbbb']"

    @OpenData
    Scenario Outline: Add new resource metadata field on the create and edit resource GUI pages
        Given "<Persona>" as the persona
        When I log in
        And I open the new resource form for dataset "public-test-dataset"
        Then I should see an element with xpath "//label[@for="field-request_privacy_assessment"]"
        And field "request_privacy_assessment" should not be required
        And I should not see an element with xpath "//label[@for="field-request_privacy_assessment"]//*[@class="control-required"]"
        And I should see an element with xpath "//select[@id="field-request_privacy_assessment"]//option[@value="" or @value="YES" or @value="NO"]"
        And I should see "Privacy risk assessment prior to public release might assist the publishing decision-making process."
        Examples: roles
        | Persona              |
        | TestOrgAdmin  |
        | TestOrgEditor |

    @Publications
    Scenario: Link resource with missing or invalid protocol should use HTTP
        Given "SysAdmin" as the persona
        When I log in
        And I create a dataset and resource with key-value parameters "notes=Testing invalid link protocol" and "name=Non-HTTP link::url=git+https://github.com/ckan/ckan.git"
        And I press "Non-HTTP link"
        Then I should see "http://git+https://github.com/ckan/ckan.git"
