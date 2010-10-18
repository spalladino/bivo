class Vote < ActiveRecord::Base

  belongs_to :user
  belongs_to :cause, :counter_cache => true

  validates_presence_of :user,:message => "inexistent user"
  validates_presence_of :cause,:message => "inexistent cause"

  validate :didnt_vote
  validate :status_of_cause

  attr_accessor :already_exists


  def status_of_cause
    if (cause && !cause.status) || (cause && cause.status != :active)
      errors.add(:cause_id, "The cause status doesnt allow voting")
    end
  end

  def didnt_vote
    if cause && user && Vote.find_by_cause_id_and_user_id(cause.id,user.id)
      self.already_exists = true
      errors.add(:cause_id, "Voted")
    end
  end


end

