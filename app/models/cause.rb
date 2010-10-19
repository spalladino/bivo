require 'enumerated_attribute'

class Cause < ActiveRecord::Base

  UrlFormat = /[a-zA-Z\-_][a-zA-Z0-9\-_]*/

  belongs_to :cause_category
  belongs_to :country
  belongs_to :charity

  has_many :votes

  validates_presence_of :name
  validates_length_of :name, :maximum => 255
  validates_uniqueness_of :name, :case_sensitive => false

  validates_presence_of :url
  validates_length_of :url, :maximum => 255
  validates_uniqueness_of :url, :case_sensitive => false
  validates_format_of :url, :with => UrlFormat

  validates_presence_of :funds_needed
  validates_numericality_of :funds_needed, :greater_than => 0

  validates_presence_of :city
  validates_length_of :city, :maximum => 255

  validates_presence_of :description
  validates_length_of :description, :maximum => 255

  validates_numericality_of :funds_raised, :greater_than_or_equal_to => 0

  enum_attr :status, %w(^inactive active raising_funds completed paid deleted)

  def can_edit
    return true
  end

  def can_mark_as_paid
    return self.funds_raised >= self.funds_needed_was
  end

  def can_delete
    return true
  end

end

