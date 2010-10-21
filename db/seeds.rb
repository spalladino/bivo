# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)


require 'open-uri'

puts "Creating countries from openconcept"
open("http://openconcept.ca/sites/openconcept.ca/files/country_code_drupal_0.txt") do |countries|
  countries.read.each_line do |country|
  code, name = country.chomp.split("|")
  Country.find_or_create_by_name name
  end
end

puts "Creating categories"
['Human Aid', 'Animal Welfare', 'Environment'].each do |category|
  CauseCategory.find_or_create_by_name category
  CharityCategory.find_or_create_by_name category
end


