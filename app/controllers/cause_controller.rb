class CauseController < ApplicationController

  before_filter :authenticate_user!, :except => [ :details, :index ]

  def details
    @cause = Cause.find_by_url(params[:url])
  end

  def index
    @causes = Cause.order('votes_count DESC').paginate(:per_page => params[:per_page] || 20, :page => params[:page])
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
      flash[:notice] = message
      render :json =>  {:message => message, :success=> success}
    else
      #NO AJAX
      flash[:notice] = message
      redirect_to request.referer
    end
  end


end

