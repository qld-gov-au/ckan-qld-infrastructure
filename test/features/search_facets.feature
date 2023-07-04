@OpenData
Feature: Search facets

    @unauthenticated
    Scenario: When I go to the dataset list page, I can see the 'Data Portals' facet
        Given "Unauthenticated" as the persona
        When I go to dataset page
        Then I should see "Data Portals"
        And I should see an element with xpath "//a[contains(@href, '?dataset_type=dataset')]/span[contains(@class, 'item-label') and contains(string(), 'data.qld.gov.au')]"
