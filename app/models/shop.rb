require 'enumerated_attribute'

class Shop < ActiveRecord::Base

  has_many :comissions
  has_many :incomes

  has_many :countries, :through => :country_shops
  has_many :country_shops, :dependent => :destroy

  has_attached_file :image, :styles => { :small => "150x150>" },
                    :url  => "/system/data/shops/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/system/data/shops/:id/:style/:basename.:extension"

  UrlFormat = /[a-zA-Z\-_][a-zA-Z0-9\-_]*/

  enum_attr :comission_kind, %w(percentage fixed_amount) do
    labels :percentage => _("percentage"), :fixed_amount => _("fixed amount")
  end

  enum_attr :status, %w(^inactive active deleted)

  enum_attr :redirection, %w(^search_box purchase_button custom_widget custom_html) do
    labels :search_box =>      _("Use a search box"),
           :purchase_button => _("Use a purchase button"),
           :custom_widget =>   _("Use a custom widget"),
           :custom_html =>     _("Use custom HTML")
  end

  validates_attachment_size :image, :less_than => 1.megabytes
  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/png']

  validates_presence_of :name
  validates_length_of   :name, :maximum => 255

  validates_presence_of :url
  validates_length_of   :url, :maximum => 255

  validates_presence_of :description
  validates_length_of   :description, :maximum => 255

  validates_presence_of   :short_url
  validates_length_of     :short_url, :maximum => 255
  validates_uniqueness_of :short_url, :case_sensitive => false
  validates               :short_url, :short_url_format => true

  validates_presence_of     :comission_value
  validates_numericality_of :comission_value, :greater_than_or_equal_to => 0
  validates_numericality_of :comission_value, :less_than_or_equal_to => 100, :if => :comission_kind_percentage?

  validates_length_of :comission_details, :maximum => 255

  #TODO: Validate widget fields

end

