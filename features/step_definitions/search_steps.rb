Given /^the following shops:$/ do |table|

  table.hashes.each do |hash|
    Shop.create! hash.merge :redirection => :search_box, :affiliate_code => 'default', :comission_value => 1, :comission_kind => :percentage, :comission_details=> 'default', :comission_recurrent => false, :affiliate_code => 'code', :status => :active
  end
    
end