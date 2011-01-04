Feature: Admin can create a cause navigating throught the charity
	Background:
		Given I fill seed data
		
		Given the following charities:
			| email			| charity_name	| short_url		|
			| charity@d.com	| charity 101	| charity101	|

	Scenario: Create a casue

		Given I am logged like "charity@d.com"
			Then I follow "My Home"

		When I click on add cause
			And I fill in "cause[name]" with "cause 202"
			And I fill in "cause[url]" with "cause202"
			And I select "Human Aid" from "cause[cause_category_id]"
			And I fill in "cause[funds_needed]" with "500"
			And I select "Argentina" from "cause[country_id]"
			And I fill in "cause[city]" with "Somewhere"
			And I fill in "cause[description]" with "lorem ipsum dolor sit amet"
			And I press "Save"

		Then I should be on cause view cause202 page
		
	Scenario: Update an inactive casue
	
		Given the following causes of "charity@d.com":
			| name 		| status   | url		|
			| cause 303 | inactive | cause303	|
			
		Given I am logged like "charity@d.com"
			Then I follow "My Home"
			Then I follow "cause 303"
					
		Then I should be on cause view cause303 page
		
		When I follow "Edit"
			And I fill in "cause[funds_needed]" with "700"
			And I fill in "cause[description]" with "lorem ipsum dolor sit amet"
			And I fill in "cause[url]" with "cause303a"
			And I press "Save"
		
		Then I should be on cause view cause303a page
		