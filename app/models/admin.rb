class Admin < User

has_many :transactions

  def is_admin_user
    return true
  end

end

