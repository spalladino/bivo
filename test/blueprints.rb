require 'machinist/active_record'
require 'sham'
require 'ffaker'

Sham.name         { Faker::Name.name }
Sham.simple_name  { Faker::Name.last_name }
Sham.bs           { Faker::Company.bs.capitalize }
Sham.description  { Faker::Company.catch_phrase }
Sham.email        { Faker::Internet.email }
Sham.url          { Faker::Internet.domain_name}
Sham.country      { Faker::Address.uk_country }
Sham.city         { Faker::Address.city }
Sham.password     { rand(36**8).to_s(36) }
Sham.funds        { rand(1000) }

Country.blueprint do
  name {Sham.country}
end

CauseCategory.blueprint do
  name {Sham.simple_name} 
end

Cause.blueprint do
  country
  city
  description
  category      {CauseCategory.make}
  
  name          {Sham.bs}
  url           {Sham.simple_name}
  funds_needed  {Sham.funds}
  funds_raised  {Sham.funds}
  status        {%w(pending_approval approved raising_funds completed)[rand(4)]}
end

PersonalUser.blueprint do
  first_name   {Sham.simple_name}
  last_name    {Sham.simple_name}
  email
  password
end

Charity.blueprint do
  charity_name     {Sham.simple_name}
  email
  password
  charity_website  {Sham.url}
  short_url        {Sham.simple_name}
  charity_type     {Sham.simple_name}
  tax_reg_number   {Sham.simple_name}
  city
end

Vote.blueprint do
  user         {PersonalUser.make}
  cause        {Cause.make}
end

class << Cause
  def make_with_votes(attributes = {})
    votes_count = attributes[:votes_count] || rand(10)
    attributes.delete(:votes_count)
    
    Cause.make(attributes) do |cause|
      votes_count.to_i.times { cause.votes.make }
    end
  end
end

