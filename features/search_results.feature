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
	
	Scenario: Paginator: 20 shops in one page (default)
		Given 20 registered shops
		
		When I go to the search page
		And I fill in "Search" with "Shop"
		And I press "Search"
		Then I should see "20 results found"
		And I should not see "Next" within ".pagination"
	
	Scenario: Paginator: 20 shops in two pages (10 records per page)
		Given 20 registered shops
		When I go to the search page
		And I select "10" from "Show per page"
		And I fill in "Search" with "Shop"
		And I press "Search"
		And I should see "Next" within ".pagination"
		
		And I should see "2" pages
	
	Scenario: Paginator: 20 shops in two pages (5 records per page)
		Given 20 registered shops
		When I go to the search page
		And I select "5" from "Show per page"
		And I fill in "Search" with "Shop"
		And I press "Search"
		And I should see "Next" within ".pagination"
		And I should see "4" pages
		
	Scenario: Paginator: Navigate found results 
		Given 30 registered shops
		When I go to the search page
		And I select "10" from "Show per page"
		And I fill in "Search" with "Shop"
		And I press "Search"
		Then I should see "30 results found"
		And I should see "Next" within ".pagination"
		And I should see "3" pages
		Then I should not see "Shop Name 19"
		
		When I follow "2" within ".pagination"
		Then I should see "Shop Name 19"
