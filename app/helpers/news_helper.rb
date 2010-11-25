module NewsHelper

  def add_news_button(newsable)
    if news_rules(newsable).can_add?(current_user,newsable.id)
      return raw("<input type=\"button\" id = \"add_news_button\" value=\"#{_("Add News")}\" onclick=\"showNewsForm(this);\"/>")
    end
  end

  def delete_news_button(id,newsable)
    if news_rules(newsable).can_delete?(current_user,newsable)
      return button_to(_("Delete"),{:action => "destroy",:controller => "news", :id => id, :newsable_id => newsable.id, :class => newsable.class.name}, :remote => true, :method => "post")
    end
  end

  def news_rules(newsable)
    eval("#{newsable.class}::NewsRules")
  end

  def cancel_news_add_button
     return raw("<input type=\"button\" id =\"cancel_news_add_button\" class=\"nodisplay\" value=\"#{_("Cancel")}\" onclick=\"cancelNewsAdd(this)\"/>")
  end


end

