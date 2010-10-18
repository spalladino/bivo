class CauseCategory < ActiveRecord::Base
  
  has_many :causes
  
  validates_presence_of :name
  
  def self.sorted_by_cause_count
    self.joins(:causes)
      .group(CauseCategory.column_names.map{|c| "#{CauseCategory.table_name}.#{c}"})
      .select("#{CauseCategory.table_name}.*, COUNT(#{Cause.table_name}.id) AS cause_count")
      .order("cause_count DESC")
  end
  
end
