Feature: Admin can create a shop
	Background:
		Given I fill seed data
		
	Scenario: The created shop is active
	
		Given I am logged like Administrator
			Then I follow "Admin Tools"
			Then I follow "Shops"
		
		When I follow "New Shop"
			And I fill in "shop[name]" with "shop ABC"
			And I fill in "shop[description]" with "shop ABC description"
			And I fill in "shop[short_url]" with "shopabc"
			And I fill in "shop[url]" with "www.shopabc.com"
			And I fill in "shop[affiliate_code]" with "http://abc.com?q=$query"			
			And I check "Worldwide"
			And I fill in "shop[comission_value]" with "4"
			And I press "Save"

		Then I should be on shop view shopabc page

		Then I press "Deactivate"
		Then I press "Activate"
