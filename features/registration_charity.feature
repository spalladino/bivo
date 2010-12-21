Feature: Visitors can register as charities
	Background:
		Given I fill seed data

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
		And I fill in "Short Url" with "charityone"
		And I select "Human Aid" from "Category"
		And I fill in "Charity Type" with "charityOneType"
		And I fill in "Tax Registration No." with "10374"
		And I select "Argentina" from "user_country_id"
		And I fill in "City" with "Buenos Aires"
		And I fill in "Description" with "Charity one description"
		And I fill in "Email" with "charityone@mail.com"
		And I fill in "Password" with "password"
		And I fill in "Password Confirmation" with "password"
		And I agree terms and conditions
		
		And I press "Create Account"
		Then I should be logged in as "charityone@mail.com"