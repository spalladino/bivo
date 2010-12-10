Feature: Visitors can register as personal users
	
	Scenario: Personal Users sign up
		When I go to the home page
			And I follow "Login"
			Then I follow "Register"
		
		When I choose personal sign up
			Then I should not see "Charity Name"
		
		When I fill in "First Name" with "John"
		And I fill in "Last Name" with "Doe"
		And I fill in "user_email" with "jhondoe@mail.com"
		And I fill in "Password" with "password"
		And I fill in "Password Confirmation" with "password"
		And I agree terms and conditions
		
		And I press "Create Account"
		Then I should be logged in as "jhondoe@mail.com"