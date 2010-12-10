Feature: Visitors can register as charities

	Scenario: Visitors can access to registration form
		When I go to the home page
			And I follow "Login"
			Then I follow "Register"
			Then I should be on sign up page
	
	Scenario: A charity fill the registration form
		When I go to the home page
			And I follow "Login"
			Then I follow "Register"
		
		When I choose charity sign up
			Then I should not see "First Name"
			
		When I fill in "Charity Name" with "Charity One"
		And I fill in "Charity Website" with "wwww.charityone.com"
		And I fill in "short_url" with "charityone"
		And I select "Human Aid" from "user_charity_category_id"
		And I fill in "Charity Type" with "charityOneType"
		And I fill in "Tax Registration Number" with "10374"
		And I select "Argentina" from "user_country_id"
		And I fill in "City" with "Buenos Aires"
		And I fill in "user[description]" with "Charity one description"
		And I fill in "user_email" with "charityone@mail.com"
		And I fill in "Password" with "password"
		And I fill in "Password Confirmation" with "password"
		And I agree terms and conditions
		
		And I press "Create Account"
		Then I should be logged in as "charityone@mail.com"