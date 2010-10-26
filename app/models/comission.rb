require 'enumerated_attribute'

class Comission < ActiveRecord::Base
  
  belongs_to :shop
  
  validates_presence_of :value
  validates_numericality_of :value, :greater_than => 0
  
  validates_presence_of :shop_id
  
  validates_length_of :details, :maximum => 255
  
  validate :percentage_less_than_100
  
  enum_attr :kind, %w(percentage fixed_amount) do
    labels :percentage => _("percentage"), :fixed_amount => _("fixed amount")
  end
  
  def percentage_less_than_100
    if self.kind_percentage? && self.value >= 100
      errors.add(:value, _("The percentage must be lower than 100%"))
    end
  end
  
end
