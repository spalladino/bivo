class Admin < User

  has_many :transactions

  def is_admin_user
    return true
  end

  def can_add_causes?
    true
  end

  enum_attr :status, %w(^active deleted),:nil => false

end

