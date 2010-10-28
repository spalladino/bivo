require 'machinist/active_record'
require 'sham'
require 'ffaker'
require "./test/blueprints_helper"


Sham.name         { "#{Faker::Name.name} #{rand(100)}" }
Sham.simple_name  { "#{Faker::Name.last_name} #{rand(100)}" }
Sham.bs           { Faker::Company.bs.capitalize }
Sham.description  { Faker::Company.catch_phrase }
Sham.email        { Faker::Internet.email }
Sham.url          { Faker::Internet.domain_name}
Sham.country      { Faker::Address.uk_county }
Sham.city         { Faker::Address.city }
Sham.password     { rand(36**8).to_s(36) }
Sham.funds        { rand(1000) }

Country.blueprint do
  name {Sham.country}
end

CauseCategory.blueprint do
  name {Sham.simple_name}
end

CharityCategory.blueprint do
  name {Sham.simple_name}
end

Cause.blueprint do
  city
  description
  status          {:active}
  charity         {Charity.make_or_get(5)}
  country         {Country.make_or_get(5)}
  cause_category  {CauseCategory.make_or_get(5)}

  name          {Sham.bs}
  url           {Sham.simple_name}
  funds_needed  {Sham.funds}
  funds_raised  {Sham.funds}
end

PersonalUser.blueprint do
  first_name   {Sham.simple_name}
  last_name    {Sham.simple_name}
  eula_accepted{true}
  email
  password
end

Admin.blueprint do
  first_name   {Sham.simple_name}
  last_name    {Sham.simple_name}
  eula_accepted{true}
  email
  password
end

Charity.blueprint do
  country          {Country.make_or_get(5)}
  charity_name     {Sham.simple_name}
  email
  password
  charity_website  {Sham.url}
  short_url        {Sham.simple_name}
  charity_type     {Sham.simple_name}
  tax_reg_number   {Sham.simple_name}
  city
  charity_category {CharityCategory.make_or_get(5)}
  eula_accepted    {true}
  status           {:active}
end

Shop.blueprint do
  name             {Sham.simple_name}
  short_url        {Sham.simple_name}
  url              {Sham.url}
  redirection      {Sham.simple_name}
  description      {Sham.simple_name}
  worldwide        {[true,false][rand(2)]}
  affiliate_code   {Sham.simple_name}
  status           {:active}
end

Vote.blueprint do
  user         {PersonalUser.make}
  cause        {Cause.make}
end

Vote.blueprint(:singleuser) do
  user         {PersonalUser.first || PersonalUser.make}
  cause        {Cause.make}
end

