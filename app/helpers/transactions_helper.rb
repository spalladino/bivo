module TransactionsHelper
  def edit_transaction_title_for(type)
    if (type == "Income")
      _("Edit Income")
    elsif (type == "Expense")
      _("Edit Expense")
    end
  end
end
