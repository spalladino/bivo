class CauseController < ApplicationController
  
  before_filter :authenticate_user!, :except => :details
  
  
  def details 
    @cause = Cause.find_by_url(params[:url])
  end
  
  def index
    @causes = Cause.order('votes_count DESC').paginate(:per_page => params[:per_page] || 20, :page => params[:page])
  end
  
  def vote
    @cause = Cause.find_by_id(params[:cause_id])
    @vote = Vote.new(params[:cause_id])
    if vote.save 
      self.custom_response "Ok",true
    else
      self.custom_response @vote.error,false
    end
  end 
  
  
  def self.custom_response(message,success)
    if request.xhr? 
      #AJAX 
      render :json =>  {:message => message, :success=> success}
    else 
      #NO AJAX
      flash[:notice] = message
      redirect :details, :url => @cause.url
    end
  end  
  
    
end
