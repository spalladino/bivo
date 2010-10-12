class AddVotesCounterToCause < ActiveRecord::Migration
  def self.up
    add_column :causes, :votes_count, :integer, :default => 0
    
    Cause.reset_column_information
    Cause.all.each do |c| 
      Cause.update_counters c.id, :votes_count => c.votes.count
    end
  end

  def self.down
    remove_column :cause, :votes_count
  end
end
