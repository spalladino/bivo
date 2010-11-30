module NewsHelper

  def add_news_button(newsable)
    if news_rules(newsable).can_add?(current_user,newsable.id)
      return raw("<input type=\"button\" id = \"add_news_button\" value=\"#{_("Add News")}\" onclick=\"showNewsForm(this);\"/>")
    end
  end

  def delete_news_button(id,newsable)
    if news_rules(newsable).can_delete?(current_user,newsable,News.find(id))
      if newsable.is_charity_user
        return button_to(_("Delete"),{
            :action => "destroy",
            :controller => "news",
            :id => id,
            :user_id => newsable.id
          },:onclick => 'disableAndContinue(this,"Deleting...")', :remote => true, :method => "post")
      else
        return button_to(_("Delete"),{
            :action => "destroy",
            :controller => "news",

            :id => id,
            :cause_id => newsable.id
          },:onclick => 'disableAndContinue(this,"Deleting...")', :remote => true, :method => "post")
      end
    end

  end

  def news_rules(newsable)
    eval("#{newsable.class}::NewsRules")
  end

  def cancel_news_add_button
     return raw("<input type=\"button\" id =\"cancel_news_add_button\" class=\"nodisplay\" value=\"#{_("Cancel")}\" onclick=\"cancelNewsAdd(this)\"/>")
  end


end

