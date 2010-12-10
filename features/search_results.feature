Feature: Search shops page

	Scenario: Not signed-in user search for an existing shop
		Given the following shops:
			| name 		| short_url		| url				| description							| worldwide	|
			| First One | first			| www.firstone.com	| The one and only shop in the world	| true		|
		
		When I go to the home page
		And I fill in "search_word" with "First"
		And I press "Go"
		
		Then I should be on search page
		And I should see "1 result found"
		And I should see "First One"
	
	Scenario: Show shops per page
		Given 20 registered shops
		
		When I go to the search page
		And I fill in "Search" with "Shop"
		And I press "Search"
				
		Then I should see "20 results found"