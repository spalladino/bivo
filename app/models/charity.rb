class Charity < User

  UrlFormat = /[a-zA-Z\-_][a-zA-Z0-9\-_]*/

  belongs_to :category, :class_name => "CharityCategory"
  belongs_to :country

  has_many :causes

  validates_presence_of :charity_name
  validates_length_of :charity_name, :maximum => 255

  validates_presence_of :charity_website
  validates_length_of :charity_website, :maximum => 255

  validates_presence_of :short_url
  validates_length_of :short_url, :maximum => 255
  validates_uniqueness_of :short_url, :case_sensitive => false

  validates_presence_of :charity_type
  validates_length_of :charity_type, :maximum => 255

  validates_presence_of :tax_reg_number
  validates_length_of :tax_reg_number, :maximum => 255

  validates_length_of :rating, :maximum => 255

  validates_length_of :rating_url, :maximum => 255

  validates_presence_of :city
  validates_length_of :city, :maximum => 255

  validates_length_of :description, :maximum => 255

  def name
    charity_name
  end

  def name=(value)
    charity_name=value
  end

  def website
    charity_website
  end

  def website=(value)
    charity_website=value
  end

  def is_charity_user
    return true
  end
end

