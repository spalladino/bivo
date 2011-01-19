# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)


puts "Creating countries from data/countries.txt"
File.open("db/data/countries.txt", 'r').each do |country|
  code, name = country.chomp.split("|")
  country = Country.find_or_create_by_name name
  country.iso = code
  country.save!
end

puts "Creating categories"
['Human Aid', 'Animal Welfare', 'Environment'].each do |category|
  CauseCategory.find_or_create_by_name category
  CharityCategory.find_or_create_by_name category
end

puts "Creating shop income category"
IncomeCategory.find_or_create_by_name IncomeCategory::ShopName


