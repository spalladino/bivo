class CauseController < ApplicationController
  
  def details 
    @cause = Cause.find_by_url(params[:url])
  end
  
  
end
