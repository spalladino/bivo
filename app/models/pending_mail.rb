require 'base64'

class PendingMail < ActiveRecord::Base
  before_save :set_default_values

  def set_default_values
    self.retries = 0 unless self.retries
  end

  def data
    Base64::decode64(self[:data])
  end

  def data=(value)
    self[:data] = Base64::encode64(value)
  end
end
