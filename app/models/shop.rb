require 'enumerated_attribute'

class Shop < ActiveRecord::Base
  
  has_many :comissions
  has_many :country_shops
  
  UrlFormat = /[a-zA-Z\-_][a-zA-Z0-9\-_]*/

  enum_attr :status, %w(^inactive active deleted)

end

