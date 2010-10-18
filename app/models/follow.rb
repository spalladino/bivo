class Follow < ActiveRecord::Base

  belongs_to :user
  belongs_to :cause

  validates_presence_of :user,:message => "inexistent user"
  validates_presence_of :cause,:message => "inexistent cause"

  validate :didnt_follow

  def didnt_follow
    if cause && user && Follow.find_by_cause_id_and_user_id(cause.id,user.id)
      errors.add(:cause_id, "Was Following")
    end
  end



end

