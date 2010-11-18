class CashPoolAccount < Account
  NAME = 'Cash Pool'
    
  def process(movement)
    # instead of processing flag, maybe a transfer that do not call a initiator of the transaction
    return if (@processing || false)
    @processing = true
    
    causes = Cause.where(:status => :raising_funds).all
    total_votes = causes.map(&:votes_count).inject { |sum,c| sum + c }
    initial_balance = self.balance
    
    causes.each do |cause|
      amount_for_cause = (initial_balance * cause.votes_count / total_votes).to_d
      Account.transfer self, Account.cause_account(cause), amount_for_cause
    end
    
    @processing = false
  end
  
end
