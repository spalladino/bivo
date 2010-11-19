class CashPoolAccount < Account
  NAME = 'Cash Pool'
    
  def process(movement)
    while self.balance > 0
      Cause.ensure_raising_funds
      causes = Cause.where(:status => :raising_funds).all
      break if causes.count == 0
      self.single_pass_transfer_funds causes
    end    
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
      
      amount_for_cause = [amount_for_cause, cause.funds_pending].min
      
      Account.transfer_no_callback_from self, Account.cause_account(cause), amount_for_cause
    end    
  end
  
end
