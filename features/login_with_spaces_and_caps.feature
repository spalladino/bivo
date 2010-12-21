Feature: Email in login is case insensitive and works ok with spaces. Personal Users.
	Background:
		Given I fill seed data
	
	Scenario: Personal Users sign up. Caps email in registration.
		When I go to the home page
			And I follow "Login"
			Then I follow "Register"
			Then I choose personal sign up
			And I fill in "First Name" with "John"
			And I fill in "Last Name" with "Doe"
			And I fill in "Email" with "JOHNDOE@MAIL.COM"
			And I fill in "Password" with "password"
			And I fill in "Password Confirmation" with "password"
			And I agree terms and conditions
			And I press "Create Account"
		Then I should be logged in as "johndoe@mail.com"
		
		When I follow "Logout"
		
		When I follow "Login"
			And I fill in "user_email" with "JOHNDOE@mail.com"
			And I fill in "user_password" with "password"
			And I press "Sign in"
		
		Then I should be logged in as "johndoe@mail.com"
		
		When I follow "Logout"
		
		When I follow "Login"
			And I fill in "user_email" with "johndoe@mail.com"
			And I fill in "user_password" with "password"
			And I press "Sign in"

		Then I should be logged in as "johndoe@mail.com"
		
		When I follow "Logout"
		
		When I follow "Login"
			And I fill in "user_email" with "johndoe@mail.com     "
			And I fill in "user_password" with "password"
			And I press "Sign in"

		Then I should be logged in as "johndoe@mail.com"
		
	Scenario: Personal Users sign up. Caps email and spaces in login.
		When I go to the home page
			And I follow "Login"
			Then I follow "Register"
			Then I choose personal sign up
			And I fill in "First Name" with "John"
			And I fill in "Last Name" with "Doe"
			And I fill in "Email" with "johndoe@mail.com"
			And I fill in "Password" with "password"
			And I fill in "Password Confirmation" with "password"
			And I agree terms and conditions
			And I press "Create Account"
		Then I should be logged in as "johndoe@mail.com"

		When I follow "Logout"

		When I follow "Login"
			And I fill in "user_email" with "JOHNDOE@MAIL.COM"
			And I fill in "user_password" with "password"
			And I press "Sign in"

		Then I should be logged in as "johndoe@mail.com"
		
		When I follow "Logout"

		When I follow "Login"
			And I fill in "user_email" with "JOHNDOE@mail.com"
			And I fill in "user_password" with "password"
			And I press "Sign in"

		Then I should be logged in as "johndoe@mail.com"

		When I follow "Logout"

		When I follow "Login"
			And I fill in "user_email" with "johndoe@mail.com      "
			And I fill in "user_password" with "password"
			And I press "Sign in"

		Then I should be logged in as "johndoe@mail.com"
	
		
		
		