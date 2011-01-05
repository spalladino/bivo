module TransactionsHelper
  def edit_transaction_title_for(type)
    if (type == "Income")
      _("Edit Income")
    elsif (type == "Expense")
      _("Edit Expense")
    end
  end

  def transactions_category_name(transaction)
    if (transaction.type == "Income")
      transaction.income_category.name rescue nil
    else
      transaction.expense_category.name rescue nil
    end
  end
end
