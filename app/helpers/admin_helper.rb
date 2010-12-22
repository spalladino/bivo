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

  def sort_arrow_for(field)
    sort_param = params[:sort_by] || "created_at-desc"
    sort_parts = sort_param.split("-")

    if (sort_parts.first.to_sym == field)
      if (sort_parts.last == "asc")
        arrow_image = "star"
      else
        arrow_image = "tabBulletInverse"
      end

      raw "<a class=\"arrow\"><img src=\"images/#{arrow_image}.png\" width=\"7\" height=\"4\" /></a>"
    else
      ""
    end
  end
end
