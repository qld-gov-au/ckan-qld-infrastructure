@google_analytics
Feature: GoogleAnalytics

    @unauthenticated
    Scenario: When viewing the HTML source code of a CKAN page, the GTM snippet is visible
        Given "Unauthenticated" as the persona
        When I go to homepage
        Then I should see an element with xpath "//script[@src='//www.googletagmanager.com/gtm.js?id=False']"

    @unauthenticated
    Scenario: When viewing the HTML source code of a group, the appropriate metadata is visible
        Given "Unauthenticated" as the persona
        When I go to group page
        And I expand the browser height
        Then I should see an element with xpath "//meta[@name='DCTERMS.title' and @content='Groups']"
        And I should see an element with xpath "//meta[@name='DCTERMS.publisher' and @content='corporateName=The State of Queensland; jurisdiction=Queensland' and @scheme='AGLSTERMS.AglsAgent']"
        And I should see an element with xpath "//meta[@name='DCTERMS.creator' and @content='c=AU; o=The State of Queensland;' and @scheme='AGLSTERMS.GOLD']"
        And I should see an element with xpath "//meta[@name='DCTERMS.description' and @content='List of all groups']"
        And I should see an element with xpath "//meta[@name='DCTERMS.jurisdiction' and @content='Queensland' and @scheme='AGLSTERMS.AglsJuri']"
        And I should see an element with xpath "//meta[@name='DCTERMS.type' and @content='Text' and @scheme='DCTERMS.DCMIType']"
        And I should see an element with xpath "//meta[@name='AGLSTERMS.documentType' and @content='index']"

        # Can't use 'I press' because the text contains an apostrophe
        # See https://github.com/ggozad/behaving/issues/137
        When I click the link with text that contains "Dave's books"
        And I press "About"
        Then I should see an element with xpath "//meta[@name='DCTERMS.title' and contains(@content, 'Dave')]"
        And I should see an element with xpath "//meta[@name='DCTERMS.publisher' and @content='corporateName=The State of Queensland; jurisdiction=Queensland' and @scheme='AGLSTERMS.AglsAgent']"
        And I should see an element with xpath "//meta[@name='DCTERMS.creator' and contains(@content, 'c=AU; o=The State of Queensland; ou=Dave') and @scheme='AGLSTERMS.GOLD']"
        And I should see an element with xpath "//meta[@name='DCTERMS.created' and @content!='' and @content!='None']"
        And I should see an element with xpath "//meta[@name='DCTERMS.description' and @content='These are books that David likes.']"
        And I should see an element with xpath "//meta[@name='DCTERMS.identifier' and @content!='' and @content!='None']"
        And I should see an element with xpath "//meta[@name='DCTERMS.jurisdiction' and @content='Queensland' and @scheme='AGLSTERMS.AglsJuri']"
        And I should see an element with xpath "//meta[@name='DCTERMS.type' and @content='Text' and @scheme='DCTERMS.DCMIType']"
        And I should see an element with xpath "//meta[@name='AGLSTERMS.documentType' and @content='guidelines']"

    @unauthenticated
    Scenario: When viewing the HTML source code of an organisation, the appropriate metadata is visible
        Given "Unauthenticated" as the persona
        When I go to organisation page
        And I expand the browser height
        Then I should see an element with xpath "//meta[@name='DCTERMS.title' and @content='Organisations']"
        And I should see an element with xpath "//meta[@name='DCTERMS.publisher' and @content='corporateName=The State of Queensland; jurisdiction=Queensland' and @scheme='AGLSTERMS.AglsAgent']"
        And I should see an element with xpath "//meta[@name='DCTERMS.creator' and @content='c=AU; o=The State of Queensland;' and @scheme='AGLSTERMS.GOLD']"
        And I should see an element with xpath "//meta[@name='DCTERMS.description' and @content='List of all organisations']"
        And I should see an element with xpath "//meta[@name='DCTERMS.jurisdiction' and @content='Queensland' and @scheme='AGLSTERMS.AglsJuri']"
        And I should see an element with xpath "//meta[@name='DCTERMS.type' and @content='Text' and @scheme='DCTERMS.DCMIType']"
        And I should see an element with xpath "//meta[@name='AGLSTERMS.documentType' and @content='index']"

        When I press "Test Organisation"
        And I press "About"
        Then I should see an element with xpath "//meta[@name='DCTERMS.title' and @content='Test Organisation']"
        And I should see an element with xpath "//meta[@name='DCTERMS.publisher' and @content='corporateName=The State of Queensland; jurisdiction=Queensland' and @scheme='AGLSTERMS.AglsAgent']"
        And I should see an element with xpath "//meta[@name='DCTERMS.creator' and @content='c=AU; o=The State of Queensland; ou=Test Organisation' and @scheme='AGLSTERMS.GOLD']"
        And I should see an element with xpath "//meta[@name='DCTERMS.created' and @content!='' and @content!='None']"
        And I should see an element with xpath "//meta[@name='DCTERMS.description' and @content='Organisation for testing issues']"
        And I should see an element with xpath "//meta[@name='DCTERMS.identifier' and @content!='' and @content!='None']"
        And I should see an element with xpath "//meta[@name='DCTERMS.jurisdiction' and @content='Queensland' and @scheme='AGLSTERMS.AglsJuri']"
        And I should see an element with xpath "//meta[@name='DCTERMS.type' and @content='Text' and @scheme='DCTERMS.DCMIType']"
        And I should see an element with xpath "//meta[@name='AGLSTERMS.documentType' and @content='guidelines']"

    Scenario: When viewing the HTML source code of a resource, the appropriate metadata is visible
        Given "TestOrgEditor" as the persona
        When I go to Dataset page
        And I expand the browser height
        Then I should see an element with xpath "//meta[@name='DCTERMS.title' and @content='Datasets']"
        And I should see an element with xpath "//meta[@name='DCTERMS.publisher' and @content='corporateName=The State of Queensland; jurisdiction=Queensland' and @scheme='AGLSTERMS.AglsAgent']"
        And I should see an element with xpath "//meta[@name='DCTERMS.creator' and @content='c=AU; o=The State of Queensland;' and @scheme='AGLSTERMS.GOLD']"
        And I should see an element with xpath "//meta[@name='DCTERMS.description' and @content='List of all datasets']"
        And I should see an element with xpath "//meta[@name='DCTERMS.jurisdiction' and @content='Queensland' and @scheme='AGLSTERMS.AglsJuri']"
        And I should see an element with xpath "//meta[@name='DCTERMS.type' and @content='Text' and @scheme='DCTERMS.DCMIType']"
        And I should see an element with xpath "//meta[@name='AGLSTERMS.documentType' and @content='index']"

        When I log in
        And I create a dataset and resource with key-value parameters "name=dcterms-testing::title=DCTERMS testing" and "url=default"
        Then I should see an element with xpath "//meta[@name='DCTERMS.title' and @content='DCTERMS testing']"
        And I should see an element with xpath "//meta[@name='DCTERMS.publisher' and @content='corporateName=The State of Queensland; jurisdiction=Queensland' and @scheme='AGLSTERMS.AglsAgent']"
        And I should see an element with xpath "//meta[@name='DCTERMS.creator' and @content='c=AU; o=The State of Queensland; ou=Test Organisation' and @scheme='AGLSTERMS.GOLD']"
        And I should see an element with xpath "//meta[@name='DCTERMS.created' and @content!='' and @content!='None']"
        And I should see an element with xpath "//meta[@name='DCTERMS.modified' and @content!='' and @content!='None']"
        And I should see an element with xpath "//meta[@name='DCTERMS.description' and @content='Description']"
        And I should see an element with xpath "//meta[@name='DCTERMS.identifier' and @content!='' and @content!='None']"
        And I should see an element with xpath "//meta[@name='DCTERMS.jurisdiction' and @content='Queensland' and @scheme='AGLSTERMS.AglsJuri']"
        And I should see an element with xpath "//meta[@name='DCTERMS.type' and @content='Text' and @scheme='DCTERMS.DCMIType']"
        And I should see an element with xpath "//meta[@name='AGLSTERMS.documentType' and @content='index']"

        When I press "Test Resource"
        Then I should see an element with xpath "//meta[@name='DCTERMS.title' and @content='Test Resource']"
        And I should see an element with xpath "//meta[@name='DCTERMS.publisher' and @content='corporateName=The State of Queensland; jurisdiction=Queensland' and @scheme='AGLSTERMS.AglsAgent']"
        And I should see an element with xpath "//meta[@name='DCTERMS.creator' and @content='c=AU; o=The State of Queensland; ou=Test Organisation' and @scheme='AGLSTERMS.GOLD']"
        And I should see an element with xpath "//meta[@name='DCTERMS.created' and @content!='' and @content!='None']"
        And I should see an element with xpath "//meta[@name='DCTERMS.modified' and @content!='' and @content!='None']"
        And I should see an element with xpath "//meta[@name='DCTERMS.description' and @content='Test Resource Description']"
        And I should see an element with xpath "//meta[@name='DCTERMS.identifier' and @content!='' and @content!='None']"
        And I should see an element with xpath "//meta[@name='DCTERMS.jurisdiction' and @content='Queensland' and @scheme='AGLSTERMS.AglsJuri']"
        And I should see an element with xpath "//meta[@name='DCTERMS.type' and @content='Text' and @scheme='DCTERMS.DCMIType']"
        And I should see an element with xpath "//meta[@name='AGLSTERMS.documentType' and @content='dataset']"
