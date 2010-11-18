class CashPoolAccount < Account
  NAME = 'Cash Pool'
    
  def process(movement)
    # instead of processing flag, maybe a transfer that do not call a initiator of the transaction
    return if (@processing || false)
    @processing = true
    
    causes = Cause.where(:status => :raising_funds)
    amount_for_cause = (self.balance / causes.count).to_d
        
    causes.each do |cause|
      Account.transfer self, Account.cause_account(cause), amount_for_cause
    end
    
    @processing = false
  end
  
end
