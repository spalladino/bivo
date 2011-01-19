require 'enumerated_attribute'

class Shop < ActiveRecord::Base
  translate :translate => [:description], \
            :index => [:name, :description, :url, :short_url]

  acts_as_commentable

  class CommentRules
    def self.before_add(comment,user)
      comment.approved = true
    end

    def self.can_delete?(user,entity,comment)
      return !user.nil? && user.is_admin_user
    end

    def self.can_edit?(user,entity)
      return !user.nil? && user.is_admin_user
    end

    def self.can_add?(user)
      return !user.nil?
    end
  end

  #Every time you modify columns in your index block, or add new index blocks,
  #you should create a new migration to updated the indexes. (rake texticle:migration and rake db:migrate)
  #If you don’t update the indexes, searches will still work as expected, they just might be kind of slow.

  has_many :comissions
  has_many :incomes

  has_many :countries, :through => :country_shops
  has_many :country_shops, :dependent => :destroy

  has_and_belongs_to_many :categories, :class_name => 'ShopCategory', :after_add => :add_parent_categories
  before_save :ensure_parent_categories

  after_save :ensure_shop_account

  has_attached_file :image, :styles => { :home => "277x176>", :search => "80x72>", :view => "208x183>", :small => "150x150>" },
    :convert_options => { :home => "-gravity center -extent 277x176", :search => "-gravity center -extent 80x72", :view => "-gravity center -extent 208x183" }

  UrlFormat = /[a-zA-Z\-_][a-zA-Z0-9\-_]*/

  enum_attr :comission_kind, %w(percentage fixed_amount) do
    labels :percentage => _("percentage"), :fixed_amount => _("fixed amount")
  end

  enum_attr :status, %w(^active inactive)

  enum_attr :redirection, %w(^search_box purchase_button custom_widget custom_html) do
    labels :search_box =>      _("Use a search box"),
           :purchase_button => _("Use a purchase button"),
           :custom_widget =>   _("Use a custom widget"),
           :custom_html =>     _("Use custom HTML")
  end

  attr_protected :status
  default_scope where('shops.status != ?',:inactive)

  validates_attachment_size :image, :less_than => 1.megabytes
  validates_attachment_content_type :image, :content_type => Bivo::Application.config.images_content_types

  validates_presence_of :name
  validates_length_of   :name, :maximum => 255
  validates_uniqueness_of :name, :case_sensitive => false

  validates_presence_of :url
  validates_length_of   :url, :maximum => 255

  validates_presence_of :description
  validates_length_of   :description, :maximum => 255

  validates_presence_of   :short_url
  validates_length_of     :short_url, :maximum => 255, :minimum => 4
  validates_uniqueness_of :short_url, :case_sensitive => false
  validates               :short_url, :short_url_format => true

  validates_presence_of     :comission_value
  validates_numericality_of :comission_value, :greater_than_or_equal_to => 0
  validates_numericality_of :comission_value, :less_than_or_equal_to => 100, :if => :comission_kind_percentage?

  validates_length_of :comission_details, :maximum => 255

  before_destroy :check_funds_on_delete

  def check_funds_on_delete
    if self.incomes.count > 0
      errors.add(:incomes, _("Can't delete shop with incomes"))
      return false
    end
  end

  #TODO: Validate widget fields
  def incomes_in_period(from, to)
    Income.where('shop_id = ? and transaction_date BETWEEN ? AND ?',self.id,from,to).sum('amount')
  end

  def incomes_in_period_rank(from,to)
 #TODO: DEFINE HOW IT RANKS
    return "" if self.incomes_in_period(from,to) <= 100
    return "cloud3" if (100..1000) === self.incomes_in_period(from,to)
    return "cloud2" if (1001..10000) === self.incomes_in_period(from,to)
    return "cloud1"
  end

  def incomes_per_month
    rows = self.incomes.group("date_part('month', transaction_date), date_part('year', transaction_date)")\
                .select("date_part('month', transaction_date) AS month, date_part('year', transaction_date) AS year, SUM(amount) AS amount")\
                .order("date_part('year', transaction_date), date_part('month', transaction_date)")

    return rows.map { |r| { :month => Date.civil(r.year.to_i, r.month.to_i, 1) , :amount => r.amount } }
  end

  def display_name
    if status == :inactive
      _("%s (Inactive)") % [name]
    else
      name
    end
  end

  # this are overriden w.r.t. enum_attr since inactive and active clash
  def status_inactive?
    status == :inactive
  end

  def search_url
    self.image.url(:search)
  end

  protected

  def add_parent_categories(category)
    if category.parent && !self.categories.include?(category.parent)
      self.categories << category.parent
    end
  end

  def ensure_parent_categories
    self.categories.each do |c|
      self.add_parent_categories c
    end
  end

  def ensure_shop_account
    Account.shop_account self
  end

  def self.all_with_inactives()
    self.with_exclusive_scope {self.scoped}
  end

  def self.all_translated_with_inactives()
    self.with_exclusive_scope {self.translated}
  end

  def self.find_with_inactives(id)
    self.all_with_inactives.find(id)
  end

  def self.find_translated_with_inactives(id)
    self.all_translated_with_inactives.find(id)
  end

end

