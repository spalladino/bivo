require './test/blueprints'

Given /^I am logged like Administrator$/ do
  user = Admin.make :password => 'secret'

  Then %(I go to the logout page)  
  Then %(I go to the login page)
  Then %(I fill in "user_email" with "#{user.email}")
  Then %(I fill in "user_password" with "secret")
  Then %(I press "Sign in")  
end
