require 'machinist/active_record'
require 'sham'
require 'ffaker'
require "./test/blueprints_helper"


Sham.name         { "#{Faker::Name.name} #{rand(100)}" }
Sham.simple_name  { "#{Faker::Name.last_name} #{rand(100)}" }
Sham.short_name   { Faker::Name.last_name.gsub(/[^0-9a-z]+/i, '') }
Sham.bs           { Faker::Company.bs.capitalize }
Sham.description  { Faker::Company.catch_phrase }
Sham.email        { Faker::Internet.email }
Sham.url          { 'http://' + Faker::Internet.domain_name}
Sham.country      { Faker::Address.uk_county }
Sham.city         { Faker::Address.city }
Sham.password     { rand(36**8).to_s(36) }
Sham.funds        { rand(1000) }
Sham.amount        { 1 + rand(1000) }

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
  url             {Sham.short_name}
  name            {Sham.bs}
  funds_needed    {Sham.funds}
  funds_raised    {0}
end

PersonalUser.blueprint do
  first_name    {Sham.simple_name}
  last_name     {Sham.simple_name}
  eula_accepted {true}
  status        {:active}
  preferred_language {:en}
  email
  password
end

Admin.blueprint do
  first_name    {Sham.simple_name}
  last_name     {Sham.simple_name}
  eula_accepted {true}
  status        {:active}
  preferred_language {:en}
  email
  password
end

Charity.blueprint do
  country          {Country.make_or_get(5)}
  charity_name     {Sham.simple_name}
  email
  description
  password
  charity_website  {Sham.url}
  short_url        {Sham.short_name}
  charity_type     {Sham.simple_name}
  tax_reg_number   {Sham.simple_name}
  preferred_language {:en}
  city
  charity_category {CharityCategory.make_or_get(5)}
  eula_accepted    {true}
  status           {:active}
end

ShopCategory.blueprint do
  name             {Sham.simple_name}
end

Shop.blueprint do
  name             {Sham.simple_name}
  short_url        {Sham.short_name}
  url              {Sham.url}
  redirection      {%w(search_box purchase_button custom_widget custom_html)[rand(4)].to_sym}
  description      {Sham.simple_name}
  worldwide        {[true,false][rand(2)]}
  affiliate_code   {Sham.simple_name}
  status           {:active}
  comission_value     {rand(10)}
  comission_kind      {:percentage}
  comission_details   {Sham.description}
  comission_recurrent {[true,false][rand(2)]}
end

Vote.blueprint do
  user         {PersonalUser.make}
  cause        {Cause.make}
end

Vote.blueprint(:singleuser) do
  user         {PersonalUser.first || PersonalUser.make}
  cause        {Cause.make}
end

Account.blueprint do
  name  { Sham.simple_name }
end

IncomeCategory.blueprint do
  name  { Sham.simple_name }
end

Gallery.blueprint do
  entity_id {Charity.make.id}
  entity_type {"Charity"}
end

GalleryItem.blueprint do
  gallery {Gallery.make}

end

Income.blueprint do
  input_amount { Sham.amount }
  input_currency { Transaction::DefaultCurrency }
  user { Admin.make }
  transaction_date { Date.today }
end

Income.blueprint(:shop) do
  income_category { IncomeCategory.get_shop_category }
  shop { Shop.make }
end

Income.blueprint(:investment) do
  income_category { IncomeCategory.make }
end
