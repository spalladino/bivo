class CharityFollow < ActiveRecord::Base

  belongs_to :user
  belongs_to :charity

  validates_presence_of :user,:message => _("inexistent user")
  validates_presence_of :charity,:message => _("inexistent charity")

   validate :didnt_follow


  def didnt_follow
    if charity && user && CharityFollow.find_by_charity_id_and_user_id(charity.id,user.id)
      errors.add(:charity_id, _("Was Following"))
    end
  end

end

