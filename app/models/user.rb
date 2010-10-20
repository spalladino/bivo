class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :from_facebook
  attr_accessible :first_name, :last_name, :nickname, :birthday, :gender, :about_me
  attr_accessible :charity_name, :charity_website, :short_url, :short_url_desc
  attr_accessible :notice_all_funds_raised, :notice_status_change, :notice_status_update_published
  attr_accessible :notice_comment_added, :send_me_news, :auto_approve_comments
  attr_accessible :charity_category_id, :charity_type, :tax_reg_number, :country_id, :city

  has_many :votes

  def is_charity_user
    false
  end

  def is_personal_user
    false
  end

  def is_admin_user
    return false
  end

  protected
    def password_required?
      (!(from_facebook && password.blank?)) && super
    end
end

