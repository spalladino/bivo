class CashPoolAccount < Account
  NAME = 'Cash Pool'
    
  def process(movement)
    # instead of processing flag, maybe a transfer that do not call a initiator of the transaction
    return if (@processing || false)
    @processing = true
    
    Cause.ensure_raising_funds
    causes = Cause.where(:status => :raising_funds).all
    return if causes.count == 0
    self.single_pass_transfer_funds causes
    
    Cause.ensure_raising_funds
    causes = Cause.where(:status => :raising_funds).all
    return if causes.count == 0
    self.single_pass_transfer_funds causes
    
    @processing = false
  end
  
protected
  
  def single_pass_transfer_funds(causes)
    total_votes = causes.map(&:votes_count).inject { |sum,c| sum + c }
    initial_balance = self.balance
    remaining_amount = initial_balance
    
    causes.each_with_index do |cause, index|
      # compute amount_for_cause using propotion of votes, but in the
      # last cause, use the remaining amount
      if index != causes.count - 1
        amount_for_cause = (initial_balance * cause.votes_count / total_votes).to_d
        remaining_amount -= amount_for_cause
      else
        amount_for_cause = remaining_amount
      end      
      
      amount_for_cause = [amount_for_cause, cause.funds_needed].min
      Account.transfer self, Account.cause_account(cause), amount_for_cause
    end    
  end
  
end
