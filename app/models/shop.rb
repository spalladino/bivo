require 'enumerated_attribute'

class Shop < ActiveRecord::Base
  
  has_many :comissions
  has_many :country_shops
  
  UrlFormat = /[a-zA-Z\-_][a-zA-Z0-9\-_]*/

  enum_attr :status, %w(^inactive active deleted)

  has_attached_file :image, :styles => { :small => "150x150>" },
                    :url  => "/system/data/shops/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/system/data/shops/:id/:style/:basename.:extension"

  validates_attachment_size :image, :less_than => 1.megabytes
  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/png']

end

