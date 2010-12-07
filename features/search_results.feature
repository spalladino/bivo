Feature: Search shops page

	Scenario: Not signed-in user search for an existing shop
		Given the following shops:
			| name | short_url | url | description | worldwide |
			| First One | first  | www.firstone.com | The one and only shop in the world | true |
		
		When I go to the home page
		And I fill in "search_word" with "First"
		And I press "Go"
		
		Then I should be on search page
		And I should see "1 result found"
		And I should see "First One"