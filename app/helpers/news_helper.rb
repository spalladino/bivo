module NewsHelper

  def add_news_button(newsable)
    if news_rules(newsable).can_add?(current_user,newsable.id)
      return raw(orange_button("<input type=\"button\" id = \"add_news_button\" class=\"buttonMid accBtnMi\" value=\"#{_("Add News")}\" onclick=\"showNewsForm(this);\"/>"))
    end
  end

  def delete_news_button(id,newsable)
    if news_rules(newsable).can_delete?(current_user,newsable,News.find(id))
      if newsable.is_charity_user
        return button_to(_("Delete"),{
            :action => "destroy",
            :controller => "news",
            :id => id,
            :user_id => newsable.id,
          },:onclick => 'if (confirm("are you sure you want to delete the news?")){disableAndContinue(this,"Deleting...")};', :remote => true,:id =>"delete_news_button_" + id.to_s , :method => "post")
      else
        return button_to(_("Delete"),{
            :action => "destroy",
            :controller => "news",
            :id => id,
            :cause_id => newsable.id
          },:onclick => 'if (confirm("are you sure you want to delete the news?")){disableAndContinue(this,"Deleting...")};', :remote => true,:id =>"delete_news_button_" + id.to_s , :method => "post")
      end
    end

  end

  def news_rules(newsable)
    eval("#{newsable.class}::NewsRules")
  end

  def submit_news_button
    return raw(orange_button("<input id=\"news_submit\" class=\"buttonMid accBtnMi\" name=\"commit\" type=\"submit\" value=\"#{_("Submit")}\">"))
  end

  def cancel_news_add_button
     return raw(orange_button("<input type=\"button\" id =\"cancel_news_add_button\" class=\"nodisplay buttonMid accBtnMi\" value=\"#{_("Cancel")}\" onclick=\"cancelNewsAdd(this)\"/>"))
  end


end

