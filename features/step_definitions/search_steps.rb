
Given /debug/ do
  p Shop.connection.execute('select current_database()')[0]
  p Shop.connection.execute('select count(*) from shops')[0]
end

Given /^(\d+) registered shops$/ do |count|
  for i in 1..count.to_i do
    Shop.create! :name => "Shop Name #{i}", :short_url => "shortUrlShop#{i}", :url => "www.shop#{i}.com.ar", :description => "Shop #{i} description", :worldwide => true, :redirection => :search_box, :affiliate_code => 'default', :comission_value => 1, :comission_kind => :percentage, :comission_details=> 'default', :comission_recurrent => false, :affiliate_code => 'code', :status => :active
  end
end

Then /^I should see "([^"]*)" pages$/ do |count|
  1.upto(count.to_i) do |i|
    Then %(I should see "#{i}" within ".pagination")
  end
  Then %(I should not see "#{count.to_i + 1}" within ".pagination")
end


