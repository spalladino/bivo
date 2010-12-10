module RegistrationsHelper
  def get_display_of(type, user)
    if (user.type)
      if (user.type.to_sym == type)
        "display:block;"
      else
        "display:none;"
      end
    else
      if (type.to_sym == :PersonalUser)
        "display:block;"
      else
        "display:none;"
      end
    end
  end
  
  def title_for(type)
    if (type == :PersonalUser)
      "Personal Account Settings"
    elsif (type == :Charity)
      "Charity Account Settings"
    else
      ""
    end
  end
end
