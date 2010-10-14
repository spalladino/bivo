class Vote < ActiveRecord::Base

  belongs_to :user
  belongs_to :cause, :counter_cache => true

  validates_presence_of :user_id
  validates_presence_of :cause_id

  validates_uniqueness_of :user_id, :scope => [:cause_id],:message => "Already voted"
  validate :status_of_cause

 def status_of_cause
  if cause && cause.status != :voting
    errors.add(:cause_id, "The cause status doesnt allow voting")
 end
end

end

