require 'enumerated_attribute'

class Cause < ActiveRecord::Base

  UrlFormat = /[a-zA-Z\-_][a-zA-Z0-9\-_]*/

  # Default scope excludes deleted causes
  default_scope where('causes.status != ?', :deleted)

  belongs_to :cause_category
  belongs_to :country
  belongs_to :charity

  has_many :votes, :dependent => :destroy

  validates_presence_of :charity
  validates_presence_of :country
  validates_presence_of :cause_category

  validates_presence_of :name
  validates_length_of :name, :maximum => 255
  validates_uniqueness_of :name, :case_sensitive => false

  validates_presence_of :url
  validates_length_of :url, :maximum => 255
  validates_uniqueness_of :url, :case_sensitive => false
  validates :url, :short_url_format => true

  validates_presence_of :funds_needed
  validates_numericality_of :funds_needed, :greater_than => 0

  validates_presence_of :city
  validates_length_of :city, :maximum => 255

  validates_presence_of :description
  validates_length_of :description, :maximum => 255

  validates_numericality_of :funds_raised, :greater_than_or_equal_to => 0

  validate :inactive_if_charity_is_inactive


  def inactive_if_charity_is_inactive
    errors.add(:status, "must be inactive when charity is inactive") if
      !self.charity.nil? and self.charity.status == :inactive and self.status != :inactive
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

  def can_change_status(to_status, from_status = self.status)
    @result = false
    case from_status
      when :inactive
        @result = to_status == :active
      when :active
        @result = [:inactive, :raising_funds].include? to_status
      when :raising_funds
        @result = [:completed, :deleted].include? to_status
      when :completed
        @result = [:paid, :deleted].include? to_status
      when :paid
        @result = [:completed, :deleted].include? to_status
    end
    @result
  end

  def destroy
    if can_delete?
      super
    else
      update_attribute :status, :deleted
    end
  end

end

