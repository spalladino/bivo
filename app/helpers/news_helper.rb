module NewsHelper

  def add_news_button(newsable)
    if news_rules(newsable).can_add?(current_user,newsable.id)
      return raw(orange_button("<input type=\"button\" id = \"add_news_button\" class=\"buttonMid accBtnMi\" value=\"#{_("Add News")}\" onclick=\"showNewsForm(this);\"/>"))
    end
  end

  def delete_news_button(id,newsable)
    if news_rules(newsable).can_delete?(current_user,newsable,News.find(id))
      target_params = {
        :action => "destroy",
        :controller => "news",
        :id => id,        
      }

      link_params = {
          :confirm => "are you sure you want to delete the news?",
          :disable_with => _('Deleting...'),
          :remote => true,
          :id =>"delete_news_button_#{id.to_s}", 
          :method => "post"
      }

      if newsable.is_charity_user
        target_params[:user_id] = newsable.id
      else
        target_params[:cause_id] = newsable.id
      end

      link_to _("Delete"), target_params, link_params
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

