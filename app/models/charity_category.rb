class CharityCategory < ActiveRecord::Base

  validates_presence_of :name

  has_many :charities

  scope :sorted_by_charities_count, joins(:charities)\
      .where('users.type = ?', Charity.name)\
      .where('users.status != ?',:inactive)\
      .group(CharityCategory.column_names.map{|c| "#{CharityCategory.table_name}.#{c}"})\
      .select("#{CharityCategory.table_name}.*, COUNT(#{Charity.table_name}.id) AS charities_count")\
      .order("charities_count DESC")
end

