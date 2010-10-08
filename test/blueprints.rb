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
