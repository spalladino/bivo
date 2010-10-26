class CountryShop < ActiveRecord::Base
  belongs_to :country
  belongs_to :shop
end
