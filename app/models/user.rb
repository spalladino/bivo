class User < ActiveRecord::Base


  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates_presence_of :type
  validates_presence_of :eula_accepted, :on => :create, :unless => :from_facebook, :message => "must be accepted"
  validate :is_captcha_valid?, :unless => :captcha_valid


  # Setup accessible (or protected) attributes for your model
  #attr_accessible *(self.column_names - [])
  attr_accessible :email, :password, :password_confirmation, :remember_me, :from_facebook, :captcha, :captcha_key
  attr_accessible :first_name, :last_name, :nickname, :birthday, :gender, :about_me
  attr_accessible :charity_name, :charity_website, :short_url, :short_url_desc
  attr_accessible :notice_all_funds_raised, :notice_status_change, :notice_status_update_published
  attr_accessible :notice_comment_added, :send_me_news, :auto_approve_comments, :eula_accepted
  attr_accessible :charity_category_id, :charity_type, :tax_reg_number, :country_id, :city

  attr_accessor_with_default :captcha_valid, true

  has_many :votes
  has_many :follows

  def is_charity_user
    false
  end

  def is_personal_user
    false
  end

  def is_admin_user
    false
  end

  # Had to overwrite it from devise because if not it asks for password every time you want to update and it's very annoying.
  def update_with_password(params={})
    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end

    result = update_attributes(params)
    clean_up_passwords
    result
  end

  def is_captcha_valid?
    unless self.captcha_valid
      errors.add("captcha", "doesnt match value")
    end

    self.captcha_valid
  end

  def set_captcha_invalid
    self.captcha_valid = false
  end

  protected
    def password_required?
      if (from_facebook || persisted?)
        false
      else
        super
      end
    end
end

