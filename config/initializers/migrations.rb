class ActiveRecord::Migration
  def self.table_exists?(name)
    ActiveRecord::Base.connection.tables.include?(name)
  end
  
  def self.tables
    ActiveRecord::Base.connection.tables
  end
end
