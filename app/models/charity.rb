class Charity < User
  acts_as_commentable

  class CommentRules

    def self.before_add(comment,user)
        entity = Charity.find(comment.commentable_id)
        comment.approved = entity.auto_approve_comments  || user == entity
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
      return !user.nil? && (user == entity || user.is_admin_user)
    end
  end

  UrlFormat = /[a-zA-Z\-_][a-zA-Z0-9\-_]*/

  # Default scope excludes deleted charities, the condition
  # is required to initialize for the first time the DB
  if User.table_exists? 
    default_scope where('users.status != ?', :deleted)

    scope :exclude_inactive, where('users.status != ?', :inactive)
  end

  scope :with_cause_data, proc { \
       joins("LEFT JOIN #{Cause.table_name} ON #{Cause.table_name}.charity_id = #{Charity.table_name}.id")\
      .joins(:country)\
      .group(self.column_names.map{|c| "#{Charity.table_name}.#{c}"})\
      .group("#{Country.table_name}.name")\
      .select("#{Charity.table_name}.*, SUM(#{Cause.table_name}.votes_count) AS votes_count, COUNT(#{Cause.table_name}.id) AS causes_count, SUM(#{Cause.table_name}.funds_raised) AS total_funds_raised, #{Country.table_name}.name AS country_name") }

  before_save :check_presence_of_protocol_in_website
  validate :inactivate_causes_on_inactivate, :on => :update

  belongs_to :charity_category
  belongs_to :country

  has_many :causes, :dependent => :destroy
  has_many :votes, :through => :causes
  has_one :gallery
  has_many :news, :as => :newsable
  attr_protected :funds_raised
  attr_protected :status

  validates_presence_of :country_id
  validates_presence_of :charity_category

  validates_presence_of :charity_name
  validates_length_of :charity_name, :maximum => 255

  validates_presence_of :charity_website
  validates_length_of :charity_website, :maximum => 255
  validates :charity_website, :url_format => true

  validates_presence_of :short_url
  validates_length_of :short_url, :maximum => 255, :minimum => 3
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
  
  validates_numericality_of :rating, :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 5, :unless => Proc.new {|c| c.rating.nil?}

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

  def can_add_causes?
    true
  end


  def destroy
    # destroy causes. without spreading the collected funds
    # until all of the causes that belongs to the charity
    # are destroyed 
    cash_pool = Account.cash_pool_account
    cash_pool.freeze_processing    
    self.causes.each do |cause|
      cause.destroy
    end
    
    # destroy self
    super
    
    # spread the collected funds
    cash_pool.process_balance
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

  def causes_to_show(user)
    if user and (user == self || user.is_admin_user)
      self.causes
    else
      self.causes.where('status != ?',:inactive)
    end
  end
  
  def first_gallery_photo
    Gallery.for_entity(self).items.all.select(&:is_photo?).first
  end

  # this are overriden w.r.t. enum_attr since inactive and active clash
  def status_inactive?
    status == :inactive
  end
  #

  def comments_avatar_url
    first_gallery_photo.try(:comments_avatar_url)
  end
    
  def has_pending_comments_in_causes
    causes.any? { |c| c.has_own_comments_to_approve? }
  end  

  private

  def check_presence_of_protocol_in_website
    unless (["http","https"].include?(self.charity_website.split(":").first))
      self.charity_website = "http://" + self.charity_website
    end
  end
  
  def inactivate_causes_on_inactivate
    if ((self.status_changed?) && (self.status == :inactive))
      self.causes.each do |cause|
        cause.status = :inactive
        if !cause.save
          errors.add(:status, _("can't inactivate charity due to cause: %s") % [cause.name])
          return false
        end
      end
    end
  end
  
end

