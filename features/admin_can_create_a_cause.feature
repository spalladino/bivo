Feature: Admin can create a cause navigating throught the charity
	Background:
		Given I fill seed data
		
		Given the following charities:
			| charity_name	| short_url		|
			| charity 101	| charity101	|

	Scenario: If the charity is active
	
		Given I am logged like Administrator
			Then I follow "Admin Tools"
			Then I follow "Charities"
			Then I follow "charity 101"
		
		When I click on add cause
			And I fill in "cause[name]" with "cause 202"
			And I fill in "cause[url]" with "cause202"
			And I fill in "cause[funds_needed]" with "500"
			And I fill in "cause[city]" with "Somewhere"
			And I fill in "cause[description]" with "lorem ipsum dolor sit amet"
			And I press "Save"

		Then I should be on cause view cause202 page


