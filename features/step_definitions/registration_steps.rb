Given /^I fill seed data$/ do
  require 'open-uri'
  open("http://openconcept.ca/sites/openconcept.ca/files/country_code_drupal_0.txt") do |countries|
    countries.read.each_line do |country|
    code, name = country.chomp.split("|")
    Country.find_or_create_by_name name
    end
  end

  ['Human Aid', 'Animal Welfare', 'Environment'].each do |category|
    CauseCategory.find_or_create_by_name category
    CharityCategory.find_or_create_by_name category
  end

  IncomeCategory.find_or_create_by_name IncomeCategory::ShopName
end

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


