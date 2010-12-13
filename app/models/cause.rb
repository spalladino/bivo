require 'enumerated_attribute'

class Cause < ActiveRecord::Base
  acts_as_commentable
  UrlFormat = /[a-zA-Z\-_][a-zA-Z0-9\-_]*/

  class CommentRules
    def self.before_add(comment,user)
        entity = Cause.find(comment.commentable_id)
        comment.approved = entity.charity.auto_approve_comments || user == entity.charity
    end

    def self.can_approve?(user,entity,comment)
      return !user.nil? && (user.is_charity_user && user.id == entity.charity.id && comment.commentable_type == "Cause" && entity.id == comment.commentable_id )
    end

    def self.can_delete?(user,entity,comment)
      return !user.nil? && (user.is_admin_user || entity.charity == user )
    end

    def self.can_edit?(user,entity)
      return !user.nil? && (user.is_admin_user || entity.charity == user )
    end

    def self.can_add?(user)
      return !user.nil?
    end
  end

  class NewsRules
    def self.can_add?(user,cause_id)
     return !user.nil? && (user.is_charity_user) && user.id == Cause.find(cause_id).charity_id
    end

    def self.can_delete?(user,cause,news)
      return !user.nil? && (user.is_admin_user || (cause.charity == user && cause.id == news.newsable_id))
    end
  end

  class GalleryRules
    def self.can_edit?(user, entity)
      return entity.charity == user
    end
  end

  # Default scope excludes deleted causes
  default_scope where('causes.status != ?', :deleted)
  has_one :gallery
  belongs_to :cause_category
  belongs_to :country
  belongs_to :charity

  has_many :news, :as => :newsable
  has_many :votes, :dependent => :destroy

  before_update do
    @status_change = true if status_changed?
  end

  after_update do
    CauseObserver.instance.status_change_persisted(self) if @status_change
  end

  after_save :ensure_cause_account

  before_validation :ensure_complete_when_funds_raised

  attr_protected :status

  validates_presence_of :charity
  validates_presence_of :country
  validates_presence_of :cause_category

  validates_presence_of :name
  validates_length_of :name, :maximum => 255
  validates_uniqueness_of :name, :case_sensitive => false

  validates_presence_of :url
  validates_length_of :url, :maximum => 255, :minimum => 3
  validates_uniqueness_of :url, :case_sensitive => false
  validates :url, :short_url_format => true

  validates_presence_of :funds_needed
  validates_numericality_of :funds_needed, :greater_than => 0
  validates :funds_needed, :decimal => true
  validates :funds_raised, :decimal => true

  validates_presence_of :city
  validates_length_of :city, :maximum => 255

  validates_presence_of :description
  validates_length_of :description, :maximum => 255

  validates_numericality_of :funds_raised, :greater_than_or_equal_to => 0

  validate :inactive_if_charity_is_inactive
  validate :valid_status_transition_if_changed, :on => :update

  def funds_pending
    self.funds_needed - self.funds_raised
  end

  def valid_status_transition_if_changed
    if ((self.status_changed?) && (!can_change_status?))
      errors.add(:status, "invalid transition")
    end
  end

  def can_change_status?
    from_status = self.status_was.to_sym
    to_status = self.status.to_sym

    case from_status
      when :inactive
        to_status == :active && self.charity.status != :inactive
      when :active
        if (to_status == :raising_funds)
          Cause.where("status = ? and cause_category_id = ?", :raising_funds, self.cause_category.id).empty?
        else
          to_status == :inactive
        end
      when :raising_funds
        [:completed, :deleted].include? to_status
      when :completed
        [:paid, :deleted].include? to_status
      when :paid
        [:completed, :deleted].include? to_status
      else
        false
    end
  end

  def is_charity_user
    return false
  end

  def inactive_if_charity_is_inactive
    errors.add(:status, "unable to create causes if charity is inactive") if
      !self.charity.nil? and self.charity.status == :inactive
  end

  enum_attr :status, %w(^inactive active raising_funds completed paid deleted),:nil => false

  def self.find_deleted(id)
    self.with_exclusive_scope {find(id)}
  end

  def self.count_deleted(charity_id = nil)
    self.with_exclusive_scope do
      cond = where('causes.status = ?', :deleted)
      cond = cond.where('causes.charity_id = ?', charity_id) if charity_id
      cond.count
    end
  end

  def self.all_deleted()
    self.with_exclusive_scope { where('causes.status = ?', :deleted).all }
  end

  def self.all_with_deleted()
    self.with_exclusive_scope { includes(:country).includes(:charity) }
  end

  def can_edit?
    [:inactive, :active, :raising_funds].include? self.status
  end

  def can_mark_as_paid?
    self.status == :completed && self.funds_raised >= self.funds_needed
  end

  def can_delete?
    [:inactive, :active].include? self.status
  end

  def can_vote?
    self.status == :active
  end

  def destroy
    if can_delete?
      super
    else
      update_attribute :status, :deleted
    end
  end

  def self.most_voted_cause(category, from=nil, to=nil)
    if (from.nil? || to.nil?)
      result = where(:cause_category_id => category.id, :status => :active)
      result = result.order("votes_count DESC, created_at ASC")
    else
      cause_columns = column_names.map{|c| "#{Cause.table_name}.#{c}"}
      result = select(cause_columns + ["count(votes.id) AS votes_in_period"])
      result = result.joins("LEFT JOIN votes ON votes.cause_id = causes.id")
      result = result.where(:cause_category_id => category.id, :status => :active)
      result = result.where("(votes.id IS NULL) OR (votes.created_at BETWEEN ? AND ?)", from, to)
      result = result.order("votes_in_period DESC, created_at ASC")
      result = result.group(cause_columns)
    end

    res = result.limit(1).first
    
    if (from.nil? || to.nil?)
      res if res && res.votes_count > 0
    else
      res if res && res.votes_in_period.to_i > 0
    end
  end

  def self.most_voted_causes(from=nil, to=nil)
    most_voted_causes = []

    CauseCategory.all.each do |cat|
      cause = Cause.most_voted_cause cat, from, to
      most_voted_causes << cause unless cause.nil?
    end

    most_voted_causes
  end


  def self.causes_being_funded(from, to)
    cause_columns = column_names.map{|c| "#{Cause.table_name}.#{c}"}
    result = Cause.select(cause_columns + ["SUM(account_movements.amount) AS funds_raised_in_period"])
    result = result.joins("INNER JOIN accounts ON accounts.cause_id = causes.id")
    result = result.joins("INNER JOIN account_movements ON account_movements.account_id = accounts.id")
    result = result.where("account_movements.created_at BETWEEN ? AND ?", from, to)
    result = result.order("cause_category_id ASC, funds_raised_in_period DESC")
    result = result.group(cause_columns)
    result.all
  end


  def self.ensure_raising_funds
    CauseCategory.all.each do |cat|
      if cat.causes.where(:status => :raising_funds).count == 0
        cause = Cause.most_voted_cause cat
        if cause
          cause.status = :raising_funds
          cause.save!
        end
      end
    end
  end

  def ensure_cause_account
    Account.cause_account self
  end

  def has_own_comments_to_approve?
    Comment.where(:commentable_id => self.id, :commentable_type => self.class.name, :approved => false).count > 0
  end

  def ensure_complete_when_funds_raised
    if self.funds_raised_changed? && self.status == :raising_funds
      if self.funds_raised >= self.funds_needed
        self.status = :completed
      end
    end
  end
end

