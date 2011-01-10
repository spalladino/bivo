class CauseCategory < ActiveRecord::Base

  has_many :causes

  validates_presence_of :name

  scope :sorted_by_causes_count, joins("LEFT JOIN causes on cause_categories.id = causes.cause_category_id")
      .group("cause_categories.id, cause_categories.name")
      .order("causes_count DESC")
      .select("cause_categories.id, cause_categories.name, COUNT(cause_categories.id) causes_count")
end

