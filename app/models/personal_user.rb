class PersonalUser < User

  validates_presence_of :first_name
  validates_length_of :first_name, :maximum => 255

  validates_presence_of :last_name
  validates_length_of :last_name, :maximum => 255

  validates_length_of :gender, :maximum => 255

  validates_length_of :about_me, :maximum => 255

  validates_uniqueness_of :nickname, :case_sensitive => false, :allow_blank => true

  def is_personal_user
    return true
  end

  def name
    "#{first_name} #{last_name}"
  end
end

