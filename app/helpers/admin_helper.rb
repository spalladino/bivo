module AdminHelper
  def get_sort_for(field)
    sort_param = params[:sort_by] || "created_at-desc"

    inverse_sort_way = {
      "asc" => "desc",
      "desc" => "asc"
    }

    sort_parts = sort_param.split("-")
    if (sort_parts.first == field)
      "#{field}-#{inverse_sort_way[sort_parts.last]}"
    else
      "#{field}-asc"
    end
  end

  def get_display_of(type, value)
    if (value.type.to_sym == type)
      "display:block;"
    else
      "display:none;"
    end
  end

  def get_shop_display(transaction)
    if ((transaction.type == "Income") && 
        (transaction.income_category) &&
        (transaction.income_category.name == "shop"))
      "display:block;"
    else
      "display:none;"
    end
  end

  def format_date(value)
    if (value.nil?)
      ""
    else
      value.strftime("%B, %d, %Y")
    end
  end
end
