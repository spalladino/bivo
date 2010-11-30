When /^I choose charity sign up$/ do
  Then %(I choose "user_type_charity")
  sleep 1
end

When /^I agree terms and conditions$/ do
  Then %(I check "user_eula_accepted")
end

Then /^I should be logged in as "([^"]*)"$/ do |mail|
  Then %(I should see "Signed in as #{mail}")
end

When /^I choose personal sign up$/ do
  Then %(I choose "user_type_personaluser")
end


