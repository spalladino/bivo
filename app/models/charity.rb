class Charity < User
  acts_as_commentable

  class CommentRules

    def self.before_add(comment)
        entity = Charity.find(comment.commentable_id)
        comment.approved = entity.auto_approve_comments
    end

    def self.can_approve?(user,entity,comment)
     return !user.nil? && (user.is_charity_user && user.id == comment.commentable_id && comment.commentable_type == "Charity")
    end

    def self.can_delete?(user,entity,comment)
      return !user.nil? && (user.is_admin_user || (user.is_charity_user && user.id == comment.commentable_id && comment.commentable_type == "Charity"))
    end

    def self.can_edit?(user,entity)
      return !user.nil? && user.is_admin_user
    end

    def self.can_add?(user)
      return !user.nil?
    end
  end

  class NewsRules
    def self.can_add?(user,charity_id)
      return !user.nil? && user.is_charity_user && user.id == charity_id
    end

    def self.can_delete?(user,charity,news)
      return !user.nil? && (user.is_admin_user || (charity == user && charity.id == news.newsable_id))
    end
  end
  
  class GalleryRules
    def self.can_edit?(user, entity)
      return user == entity
    end
  end

  attr_protected :status

  UrlFormat = /[a-zA-Z\-_][a-zA-Z0-9\-_]*/
  # Default scope excludes deleted charities
  default_scope where('users.status != ?', :deleted)

  scope :with_cause_data, proc { where('users.status != ?', :inactive)
      .joins("LEFT JOIN #{Cause.table_name} ON #{Cause.table_name}.charity_id = #{Charity.table_name}.id")\
      .joins(:country)\
      .group(self.column_names.map{|c| "#{Charity.table_name}.#{c}"})\
      .group("#{Country.table_name}.name")\
      .select("#{Charity.table_name}.*, SUM(#{Cause.table_name}.votes_count) AS votes_count, COUNT(#{Cause.table_name}.id) AS causes_count, SUM(#{Cause.table_name}.funds_raised) AS total_funds_raised, #{Country.table_name}.name AS country_name") }

  before_save :check_presence_of_protocol_in_website

  belongs_to :charity_category
  belongs_to :country

  has_many :causes, :dependent => :destroy
  has_many :votes, :through => :causes
  has_one :gallery
  has_many :news, :as => :newsable
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

  #validate :inactive_at_first, :on => :create

  #def inactive_at_first
  #  if self.status != :inactive
  #    errors.add(:status, _("the Charity must be inactive") )
  #  end
  #end
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

  def can_add_causes?
    true
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

  def comments_to_approve_count
    count = Comment.where(:commentable_id => self.id, :commentable_type => self.class.name, :approved => false).count
    self.causes.each do |cause|
    count = count + Comment.where(:commentable_id => cause.id, :commentable_type => cause.class.name, :approved => false).count
    end
    return count
  end

  def has_own_comments_to_approve?
    Comment.where(:commentable_id => self.id, :commentable_type => self.class.name, :approved => false).count > 0
  end

  private

  def check_presence_of_protocol_in_website
    unless (["http","https"].include?(self.charity_website.split(":").first))
      self.charity_website = "http://" + self.charity_website
    end
  end
end

