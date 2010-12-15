class CauseAccount < Account
  belongs_to :cause
  def cause
    # overriden in order to get deleted cause (out of default scope)
    @cause = @cause || Cause.find_deleted(self.cause_id)
  end

  after_update :update_cause_funds

  protected

  def update_cause_funds
    self.cause.funds_raised = self.balance
    self.cause.save!
  end

end
