class CausesController < ApplicationController

  before_filter :authenticate_user!, :except => [ :details, :index ]

  def details
    @cause = Cause.find_by_url(params[:url])
  end

  def index
    @causes = Cause.order('votes_count DESC').includes(:country).includes(:charity)

    # Filter by region
    if not params[:region].blank?
      @causes = @causes.where('country_id = ?', params[:region].to_i)
    end

    # Filter by status
    status = params[:status] || :active
    @causes = @causes.where('status = ?', status)

    # Filter by category
    if not params[:category].blank?
      @causes = @causes.where('category_id = ?', params[:category].to_i)
    end

    # Cap maximum to show to 50
    @causes = @causes[0...50]

    # Set pagination
    @causes = @causes.paginate(:per_page => params[:per_page] || 20, :page => params[:page])

    # Fill filters fields
    if not request.xhr?
      @regions = Country.all
      @region = params[:region]

      @statuses = Cause.enumerated_attributes[:status]
      @status = status
      
      @categories = CauseCategory.sorted_by_cause_count[0...6]
      @category = params[:category]
    end
  end

  def vote
    @cause = Cause.find_by_id(params[:cause_id])
    @vote = Vote.new(params[:cause_id])
    if @vote.save
      custom_response "Ok",true
    else
      custom_response @vote.errors.on(:cause_id) ,false
    end
  end

  def follow
    redirect_to request.referer
  end

  def custom_response(message,success)
    if request.xhr?
      #AJAX
      flash[:notice] = message
      @message =  message
      @success = success
    else
      #NO AJAX
      flash[:notice] = message
      redirect_to request.referer
    end

  end


  def new
    @cause = Cause.new
  end

  def edit
    @cause = Cause.find_by_id(params[:id])
  end

  def create
    @cause = Cause.new params[:cause]
    @cause.funds_raised = 0
    @cause.charity_id = current_user.id
    if !@cause.save
      render 'new'
    else
      redirect_to root_url
    end
  end
  
  def update
    @cause = Cause.find_by_id(params[:id])
    @cause.attributes = params[:cause]
    if !@cause.save
      render 'edit'
    else
      redirect_to root_url
    end
  end

end

