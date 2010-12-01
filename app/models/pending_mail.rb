class PendingMail < ActiveRecord::Base
  before_save :set_default_values

  def set_default_values
    self.retries = 0 unless self.retries
  end
end
