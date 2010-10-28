class CountryShop < ActiveRecord::Base
  belongs_to :country
  belongs_to :shop
  
  validates_presence_of :shop_id, :country_id
  validate :not_already_in_country
  
  def not_already_in_country
    if CountryShop.find_by_country_id_and_shop_id(self.country_id, self.shop_id)
      errors.add(:country_id, _("the country is already recomended for the shop") )
    end
  end
end
