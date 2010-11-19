class CauseAccount < Account
  belongs_to :cause

  after_update :update_cause_funds

  protected

  def update_cause_funds
    self.cause.funds_raised = self.balance
    self.cause.save!
  end

end
