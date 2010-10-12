class CauseController < ApplicationController
  
  def details 
    @cause = Cause.find_by_url(params[:url])
  end
  
  def index
    @causes = Cause.order('votes_count DESC').paginate(:per_page => params[:per_page] || 20, :page => params[:page])
  end
  
end
