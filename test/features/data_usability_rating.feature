@data_usability_rating
@OpenData
Feature: Data usability rating

    Scenario Outline: As a publisher, when I create a resource with an open license, I can verify the openness score is correct
        Given "TestOrgEditor" as the persona
        When I log in
        And I create a dataset and resource with key-value parameters "license=other-open" and "format=<Format>::upload=<Filename>"
        And I press the element with xpath "//ol[contains(@class, 'breadcrumb')]//a[starts-with(@href, '/dataset/')]"
        And I reload page every 3 seconds until I see an element with xpath "//div[contains(@class, 'qa') and contains(@class, 'openness-')]" but not more than 6 times
        Then I should see "Data usability rating"
        When I press "Test Resource"
        Then I should see an element with xpath "//div[contains(@class, 'qa openness-<Score>')]"

        Examples: Formats
            | Format | Filename           | Score |
            | HTML   | html_resource.html | 0     |
            | TXT    | txt_resource.txt   | 1     |
            | XLS    | xls_resource.xls   | 2     |
            | CSV    | csv_resource.csv   | 3     |
            | JSON   | json_resource.json | 3     |
            | RDF    | rdf_resource.rdf   | 4     |
