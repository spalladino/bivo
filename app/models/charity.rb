class Charity < User

  UrlFormat = /[a-zA-Z\-_][a-zA-Z0-9\-_]*/

  # Default scope excludes deleted charities
  default_scope where('users.status != ?', :deleted)

  scope :with_cause_data, proc { joins("LEFT JOIN #{Cause.table_name} ON #{Cause.table_name}.charity_id = #{Charity.table_name}.id")\
      .joins(:country)\
      .group(self.column_names.map{|c| "#{Charity.table_name}.#{c}"})\
      .group("#{Country.table_name}.name")\
      .select("#{Charity.table_name}.*, SUM(#{Cause.table_name}.votes_count) AS votes_count, COUNT(#{Cause.table_name}.id) AS causes_count, SUM(#{Cause.table_name}.funds_raised) AS total_funds_raised, #{Country.table_name}.name AS country_name") }

  belongs_to :charity_category
  belongs_to :country

  has_many :causes, :dependent => :destroy
  has_many :votes, :through => :causes

  attr_protected :funds_raised



  validates_presence_of :country_id
  validates_presence_of :charity_category

  validates_presence_of :charity_name
  validates_length_of :charity_name, :maximum => 255

  validates_presence_of :charity_website
  validates_length_of :charity_website, :maximum => 255
  validates :charity_website, :url_format => true

  validates_presence_of :short_url
  validates_length_of :short_url, :maximum => 255
  validates_uniqueness_of :short_url, :case_sensitive => false
  validates :short_url, :short_url_format => true

  validates_presence_of :charity_type
  validates_length_of :charity_type, :maximum => 255

  validates_presence_of :tax_reg_number
  validates_length_of :tax_reg_number, :maximum => 255

  validates_length_of :rating, :maximum => 255

  validates_length_of :rating_url, :maximum => 255

  validates_presence_of :city
  validates_length_of :city, :maximum => 255

  validates_presence_of :description
  validates_length_of :description, :maximum => 255

  enum_attr :status, %w(^inactive active deleted),:nil => false

  def self.find_deleted(id)
    self.with_exclusive_scope {find(id)}
  end

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

  def category
    charity_category
  end

  def category=(value)
    charity_category=value
  end

  def is_charity_user
    return true
  end

  def raising_funds
    return !self.causes.where('causes.status IN (?,?,?)', :raising_funds, :completed, :paid).first.nil? || Cause.count_deleted(self.id) > 0
  end

  def can_delete?
    return (not raising_funds)
  end

  def destroyed?
    super || self.status == :deleted
  end

  def destroy
    if can_delete?
      super
    else
      update_attribute :status, :deleted
      self.causes.each do |cause|
        cause.destroy
      end
    end
  end

end

