class FacebookAuthenticationsController < ApplicationController
  def index
    @authentications = current_user.authentications if current_user
  end

  def create
    user_raw_data = request.env["rack.auth"]
    user_info = {
      "first_name" => user_raw_data["user_info"]["first_name"],
      "last_name"  => user_raw_data["user_info"]["last_name"],
      "email"      => user_raw_data["extra"]["user_hash"]["email"],
      "from_facebook" => true,
      "preferred_language" => 'en'
    }

    user = User.find_by_facebook_email(user_info["email"])

    if (user)
      if (user.from_facebook)
        flash[:notice] = _("Signed in succesfully")
        sign_in_and_redirect :user, user
      else
        flash[:notice] = _("You already have an account in bivo. Please use it instead.")
        redirect_to root_path
      end
    else
      user = PersonalUser.new(user_info)
      user.facebook_email = user.email
      if (user.save)
        flash[:notice] = _("Signed in succesfully")
        sign_in_and_redirect :user, user
      else
        flash[:notice] = _("There was an error creating the user")
        redirect_to root_path
      end
    end
  end
end

