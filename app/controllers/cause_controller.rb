class CauseController < ApplicationController
  
  before_filter :authenticate_user!, :except => [ :details, :index ]
  
  def details 
    @cause = Cause.find_by_url(params[:url])
  end
  
  def index
    @causes = Cause.order('votes_count DESC').includes(:country)
    
    # Filter by region
    if not params[:filter_region].blank?
      @causes = @causes.where('country_id = ?', params[:filter_region].to_i)
    end
    
    # Filter by status
    if not params[:filter_status].blank?
      @causes = @causes.where('status = ?', params[:filter_status].to_i)
    end
    
    # Set pagination
    @causes = @causes.paginate(:per_page => params[:per_page] || 20, :page => params[:page])
    
    # Fill filters fields
    if not request.xhr?
      @regions = Country.all
      @filter_region = params[:filter_region]
      @statuses = []
      @filter_status = params[:filter_status]
    end
  end
  
  def vote
    @cause = Cause.find_by_id(params[:cause_id])
    @vote = Vote.new(params[:cause_id])
    if @vote.save 
      custom_response "Ok",true
    else
      custom_response @vote.errors.on(:user_id) ,false
    end
  end 
  
  def custom_response(message,success)
    if request.xhr? 
      #AJAX 
      render :json =>  {:message => message, :success=> success}
    else 
      #NO AJAX
      flash[:notice] = message
      redirect_to request.referer
    end
  end  
    
end
