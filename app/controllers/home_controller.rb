class HomeController < ApplicationController
  skip_before_filter :check_eula_accepted, :only => [:accept_eula, :confirm_eula]

  def eula
    
  end

  def accept_eula
    unless (user_signed_in? && !current_user.eula_accepted)
      redirect_to root_path
    end
  end

  def confirm_eula
    if (params[:eula_accepted])
      current_user.eula_accepted = true
      current_user.save
    end

    redirect_to root_path
  end
end

