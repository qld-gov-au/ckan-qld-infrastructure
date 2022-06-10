@smoke @login
Feature: Login

    Scenario: Smoke test to ensure Login step works
        Given "SysAdmin" as the persona
        When I log in
        Then I take a screenshot
        And I should see an element with xpath "//meta[@name='DCTERMS.publisher' and @content='corporateName=The State of Queensland; jurisdiction=Queensland' and @scheme='AGLSTERMS.AglsAgent']"
        And I should see an element with xpath "//meta[@name='DCTERMS.jurisdiction' and @content='Queensland' and @scheme='AGLSTERMS.AglsJuri']"
        And I should see an element with xpath "//meta[@name='DCTERMS.type' and @content='Text' and @scheme='DCTERMS.DCMIType']"
