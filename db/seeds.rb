# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)


require 'open-uri'

puts "Loading Countries"
Country.delete_all
  open("http://openconcept.ca/sites/openconcept.ca/files/country_code_drupal_0.txt") do |countries|
  countries.read.each_line do |country|
  code, name = country.chomp.split("|")
  Country.create!(:name => name) #can use code too.
  end
end

puts "Done, Countries count:" + Country.count.to_s

