class CreateTransactions < ActiveRecord::Migration
  def self.up
    create_table :transactions do |t|
      
      #common fields
      t.references :user
      t.date :transaction_date
      t.float :amount
      t.string :description, :limit => 255
      
      #income fields
      t.references :income_category
      #later will need to add shop id when shop table is created
   
      #expense fields
      t.references :expense_category
      t.string :paid_to, :limit => 255

      t.timestamps
    end
  end

  def self.down
    drop_table :transactions
  end
end
