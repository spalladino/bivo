
Given /^I am logged like "([^"]*)"$/ do |email|
  Then %(I go to the logout page)  
  Then %(I go to the login page)
  Then %(I fill in "user_email" with "#{email}")
  Then %(I fill in "user_password" with "secret")
  Then %(I press "Sign in")
end
