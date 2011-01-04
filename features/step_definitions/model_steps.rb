require './test/blueprints'

Given /^the following charities:$/ do |table|

  table.hashes.each do |hash|
    Charity.make hash.merge :password => 'secret'
  end

end

Given /^the following personal users:$/ do |table|

  table.hashes.each do |hash|
    PersonalUser.make hash.merge :password => 'secret'
  end

end

Given /^the following shops:$/ do |table|

  table.hashes.each do |hash|
    Shop.create! hash.merge :redirection => :search_box, :affiliate_code => 'default', :comission_value => 1, :comission_kind => :percentage, :comission_details=> 'default', :comission_recurrent => false, :affiliate_code => 'code', :status => :active
  end
  
end

Given /^the following causes of "([^"]*)":$/ do |charity_email, table|  
  charity = Charity.find_by_email charity_email
  
  table.hashes.each do |hash|
    Cause.make hash.merge :charity => charity
  end
end

Given /^wait$/ do
  sleep 120
end