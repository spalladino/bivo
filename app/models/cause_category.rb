class CauseCategory < ActiveRecord::Base

  has_many :causes

  validates_presence_of :name

  scope :sorted_by_causes_count, joins(:causes)\
      .group(CauseCategory.column_names.map{|c| "#{self.table_name}.#{c}"})\
      .select("#{self.table_name}.*, COUNT(#{Cause.table_name}.id) AS causes_count")\
      .order("causes_count DESC")

end

