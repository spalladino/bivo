class Account < ActiveRecord::Base

  has_many :movements, :class_name => "AccountMovement"

  def self.cash_reserves_account
    CashReservesAccount.find_or_create_by_name(CashReservesAccount::NAME)
  end

  def self.cash_pool_account
    CashPoolAccount.find_or_create_by_name(CashPoolAccount::NAME)
  end

  def self.investments_account
    InvestmentsAccount.find_or_create_by_name(InvestmentsAccount::NAME)
  end

  def self.shop_account(shop)
    account = ShopAccount.find_by_shop_id shop.id
    if account.nil?
      account = ShopAccount.new :name => shop.name, :shop => shop
      account.save!
    end
    account
  end
  
  def self.cause_account(cause)
    account = CauseAccount.find_by_cause_id cause.id
    if account.nil?
      account = CauseAccount.new :name => cause.name, :cause => cause
      account.save!
    end
    account
  end

  def self.transfer(from, to, amount, description = nil, transaction = nil)
    reload = false
    Account.transaction do
      from.lock!
      to.lock!
            
      from.balance -= amount
      from.save!
      from_line = AccountMovement.new :description => description, :amount => -amount, :balance => from.balance, :transaction => transaction
      from.movements << from_line
      
      to.balance += amount
      to.save!
      to_line = AccountMovement.new :description => description, :amount => amount, :balance => to.balance, :transaction => transaction
      to.movements << to_line
      
      begin
        from.process from_line
        to.process to_line
      rescue
        reload = true
        raise ActiveRecord::Rollback
      end
    end
    
    if reload
      from.reload
      to.reload
    end
  end
  
  # this is called during the amount transfer between accounts
  # account balance is already updated and movement is recorded
  # if exception is raised, the transfer is reverted
  def process(movement)
  end
end
