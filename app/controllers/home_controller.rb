class HomeController < ApplicationController
  def eula
    render :text => "This is about you and your rights."
  end

  def accept_eula
    
  end
end

