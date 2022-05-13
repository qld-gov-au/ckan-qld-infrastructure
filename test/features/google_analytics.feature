@google-analytics
Feature: GoogleAnalytics

    Scenario: When viewing the HTML source code of a CKAN page, the GTM snippet is visible
        When I go to homepage
        Then I should see an element with xpath "//script[@src='//www.googletagmanager.com/gtm.js?id=False']"

    Scenario: When viewing the HTML source code of a dataset, the organisation meta data is visible
        When I go to Dataset page
        And I click the link with text that contains "Department of Health Spend Data"
        Then I should see an element with xpath "//meta[@name='DCTERMS.creator' and @content='c=AU; o=The State of Queensland; ou=Department of Health' and @scheme='AGLSTERMS.GOLD']"

    Scenario: When viewing the HTML source code of a resource, the organisation meta data is visible
        When I go to Dataset page
        And I click the link with text that contains "A Novel By Tolstoy"
        And I click the link with text that contains "Full text"
        Then I should see an element with xpath "//meta[@name='DCTERMS.creator' and @content='c=AU; o=The State of Queensland; ou=Test Organisation' and @scheme='AGLSTERMS.GOLD']"

    @Publications
    Scenario: When viewing the HTML source code of a group, the appropriate metadata is visible
        When I go to group page
        Then I should see an element with xpath "//meta[@name='DCTERMS.title' and @content='Groups']"
        And I should see an element with xpath "//meta[@name='DCTERMS.publisher' and @content='corporateName=The State of Queensland; jurisdiction=Queensland' and @scheme='AGLSTERMS.AglsAgent']"
        And I should see an element with xpath "//meta[@name='DCTERMS.creator' and @content='c=AU; o=The State of Queensland;' and @scheme='AGLSTERMS.GOLD']"
        And I should see an element with xpath "//meta[@name='DCTERMS.description' and @content='List of all groups']"
        And I should see an element with xpath "//meta[@name='DCTERMS.jurisdiction' and @content='Queensland' and @scheme='AGLSTERMS.AglsJuri']"
        And I should see an element with xpath "//meta[@name='DCTERMS.type' and @content='Text' and @scheme='DCTERMS.DCMIType']"
        And I should see an element with xpath "//meta[@name='AGLSTERMS.documentType' and @content='index']"

        When I click the link with text that contains "Dave's books"
        And I click the link with text that contains "About"
        Then I should see an element with xpath "//meta[@name='DCTERMS.title' and contains(@content, 'Dave')]"
        And I should see an element with xpath "//meta[@name='DCTERMS.publisher' and @content='corporateName=The State of Queensland; jurisdiction=Queensland' and @scheme='AGLSTERMS.AglsAgent']"
        And I should see an element with xpath "//meta[@name='DCTERMS.creator' and contains(@content, 'c=AU; o=The State of Queensland; ou=Dave') and @scheme='AGLSTERMS.GOLD']"
        And I should see an element with xpath "//meta[@name='DCTERMS.created' and @content != '' and @content != 'None']"
        And I should see an element with xpath "//meta[@name='DCTERMS.description' and @content='These are books that David likes.']"
        And I should see an element with xpath "//meta[@name='DCTERMS.identifier' and @content != '' and @content != 'None']"
        And I should see an element with xpath "//meta[@name='DCTERMS.jurisdiction' and @content='Queensland' and @scheme='AGLSTERMS.AglsJuri']"
        And I should see an element with xpath "//meta[@name='DCTERMS.type' and @content='Text' and @scheme='DCTERMS.DCMIType']"
        And I should see an element with xpath "//meta[@name='AGLSTERMS.documentType' and @content='guidelines']"

    @Publications
    Scenario: When viewing the HTML source code of an organisation, the appropriate metadata is visible
        When I go to organisation page
        Then I should see an element with xpath "//meta[@name='DCTERMS.title' and @content='Organisations']"
        And I should see an element with xpath "//meta[@name='DCTERMS.publisher' and @content='corporateName=The State of Queensland; jurisdiction=Queensland' and @scheme='AGLSTERMS.AglsAgent']"
        And I should see an element with xpath "//meta[@name='DCTERMS.creator' and @content='c=AU; o=The State of Queensland;' and @scheme='AGLSTERMS.GOLD']"
        And I should see an element with xpath "//meta[@name='DCTERMS.description' and @content='List of all organisations']"
        And I should see an element with xpath "//meta[@name='DCTERMS.jurisdiction' and @content='Queensland' and @scheme='AGLSTERMS.AglsJuri']"
        And I should see an element with xpath "//meta[@name='DCTERMS.type' and @content='Text' and @scheme='DCTERMS.DCMIType']"
        And I should see an element with xpath "//meta[@name='AGLSTERMS.documentType' and @content='index']"

        When I click the link with text that contains "Department of Health"
        And I click the link with text that contains "About"
        Then I should see an element with xpath "//meta[@name='DCTERMS.title' and @content='Department of Health']"
        And I should see an element with xpath "//meta[@name='DCTERMS.publisher' and @content='corporateName=The State of Queensland; jurisdiction=Queensland' and @scheme='AGLSTERMS.AglsAgent']"
        And I should see an element with xpath "//meta[@name='DCTERMS.creator' and @content='c=AU; o=The State of Queensland; ou=Department of Health' and @scheme='AGLSTERMS.GOLD']"
        And I should see an element with xpath "//meta[@name='DCTERMS.created' and @content != '' and @content != 'None']"
        And I should see an element with xpath "//meta[@name='DCTERMS.description' and @content='Department of Health']"
        And I should see an element with xpath "//meta[@name='DCTERMS.identifier' and @content != '' and @content != 'None']"
        And I should see an element with xpath "//meta[@name='DCTERMS.jurisdiction' and @content='Queensland' and @scheme='AGLSTERMS.AglsJuri']"
        And I should see an element with xpath "//meta[@name='DCTERMS.type' and @content='Text' and @scheme='DCTERMS.DCMIType']"
        And I should see an element with xpath "//meta[@name='AGLSTERMS.documentType' and @content='guidelines']"

    @Publications
    Scenario: When viewing the HTML source code of a resource, the appropriate metadata is visible
        When I go to Dataset page
        Then I should see an element with xpath "//meta[@name='DCTERMS.title' and @content='Datasets']"
        And I should see an element with xpath "//meta[@name='DCTERMS.publisher' and @content='corporateName=The State of Queensland; jurisdiction=Queensland' and @scheme='AGLSTERMS.AglsAgent']"
        And I should see an element with xpath "//meta[@name='DCTERMS.creator' and @content='c=AU; o=The State of Queensland;' and @scheme='AGLSTERMS.GOLD']"
        And I should see an element with xpath "//meta[@name='DCTERMS.description' and @content='List of all datasets']"
        And I should see an element with xpath "//meta[@name='DCTERMS.jurisdiction' and @content='Queensland' and @scheme='AGLSTERMS.AglsJuri']"
        And I should see an element with xpath "//meta[@name='DCTERMS.type' and @content='Text' and @scheme='DCTERMS.DCMIType']"
        And I should see an element with xpath "//meta[@name='AGLSTERMS.documentType' and @content='index']"

        When I click the link with text that contains "A Novel By Tolstoy"
        Then I should see an element with xpath "//meta[@name='DCTERMS.title' and @content='A Novel By Tolstoy']"
        And I should see an element with xpath "//meta[@name='DCTERMS.publisher' and @content='corporateName=The State of Queensland; jurisdiction=Queensland' and @scheme='AGLSTERMS.AglsAgent']"
        And I should see an element with xpath "//meta[@name='DCTERMS.creator' and @content='c=AU; o=The State of Queensland; ou=Test Organisation' and @scheme='AGLSTERMS.GOLD']"
        And I should see an element with xpath "//meta[@name='DCTERMS.created' and @content != '' and @content != 'None']"
        And I should see an element with xpath "//meta[@name='DCTERMS.modified' and @content != '' and @content != 'None']"
        And I should see an element with xpath "//meta[@name='DCTERMS.description' and contains(@content, 'Some bolded text.')]"
        And I should see an element with xpath "//meta[@name='DCTERMS.identifier' and @content != '' and @content != 'None']"
        And I should see an element with xpath "//meta[@name='DCTERMS.jurisdiction' and @content='Queensland' and @scheme='AGLSTERMS.AglsJuri']"
        And I should see an element with xpath "//meta[@name='DCTERMS.type' and @content='Text' and @scheme='DCTERMS.DCMIType']"
        And I should see an element with xpath "//meta[@name='AGLSTERMS.documentType' and @content='index']"

        When I click the link with text that contains "Full text"
        Then I should see an element with xpath "//meta[@name='DCTERMS.title' and @content='Full text']"
        And I should see an element with xpath "//meta[@name='DCTERMS.publisher' and @content='corporateName=The State of Queensland; jurisdiction=Queensland' and @scheme='AGLSTERMS.AglsAgent']"
        And I should see an element with xpath "//meta[@name='DCTERMS.creator' and @content='c=AU; o=The State of Queensland; ou=Test Organisation' and @scheme='AGLSTERMS.GOLD']"
        And I should see an element with xpath "//meta[@name='DCTERMS.created' and @content != '' and @content != 'None']"
        And I should see an element with xpath "//meta[@name='DCTERMS.modified' and @content != '' and @content != 'None']"
        And I should see an element with xpath "//meta[@name='DCTERMS.description' and contains(@content, 'Full text. Needs escaping')]"
        And I should see an element with xpath "//meta[@name='DCTERMS.identifier' and @content != '' and @content != 'None']"
        And I should see an element with xpath "//meta[@name='DCTERMS.jurisdiction' and @content='Queensland' and @scheme='AGLSTERMS.AglsJuri']"
        And I should see an element with xpath "//meta[@name='DCTERMS.type' and @content='Text' and @scheme='DCTERMS.DCMIType']"
        And I should see an element with xpath "//meta[@name='AGLSTERMS.documentType' and @content='dataset']"
