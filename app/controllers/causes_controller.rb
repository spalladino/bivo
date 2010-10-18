class CausesController < ApplicationController

  before_filter :authenticate_user!, :except => [ :show, :details, :index ]

  before_filter :load_cause, :except => [ :details, :index, :new, :check_url, :create ]
  
  before_filter :only_owner_or_creator, :only => [:delete, :edit, :activate, :deactivate]

  def show
    render 'details'
  end

  def details
    @cause = Cause.find_by_url! params[:url]
  end

  def index
    @causes = Cause.order('votes_count DESC').includes(:country).includes(:charity).limit(50)
    @categories = CauseCategory.sorted_by_cause_count

    # Filter by region
    if not params[:region].blank?
      @causes = @causes.where('causes.country_id = ?', params[:region].to_i)
      @categories = @categories.where('causes.country_id = ?', params[:region].to_i)
    end

    # Filter by status
    status = params[:status] || :active
    @causes = @causes.where('causes.status = ?', status)
    @categories = @categories.where('causes.status = ?', status)

    # Count for all causes
    all_causes_count = @causes.size

    # Filter by category
    if not params[:category].blank?
      @causes = @causes.where('causes.cause_category_id = ?', params[:category].to_i)
    end

    # Cap maximum to show to 50
    @causes = @causes[0...50]

    # Set pagination
    @per_page = (params[:per_page] || 5).to_i
    @causes = @causes.paginate(:per_page => @per_page, :page => params[:page])

    # Fill filters fields
    @regions = Country.all
    @region = params[:region]

    @statuses = [:active, :raising_funds, :completed]
    @status = status

    @categories = @categories[0...6].insert(0, all_category(all_causes_count))
    @category = params[:category]
    
    @page_sizes = [5,10,20,50] 
  end


  def vote
    @vote = Vote.new(:cause_id => params[:id],:user_id=> current_user.id)
    if @vote.save
      flash[:notice] = "Vote submitted"
      redirect_to request.referer unless request.xhr? #Not Ajax
    else
      flash[:notice] = @vote.errors.on(:cause_id)
      redirect_to request.referer unless request.xhr? #Not Ajax
    end
  end

  def follow
    @follow = Follow.new(:cause_id => params[:id],:user_id=> current_user.id)
    if @follow.save
      flash[:notice] = "Follow submitted"
      if not request.xhr? #Not Ajax?
        redirect_to request.referer
      end
    else
      flash[:notice] = "Error, try again"
      if not request.xhr?
        redirect_to request.referer
      end
    end
  end

  def unfollow
    follow = Follow.find_by_cause_id_and_user_id(params[:id], current_user.id)
    follow.destroy
    if follow.destroyed?
      flash[:notice] = "Unfollow submitted"
      if not request.xhr? #Not Ajax?
        redirect_to request.referer
      end
    else
      flash[:notice] = "Error, try again"
      if !request.xhr?
        redirect_to request.referer
      end
    end
  end


  def new
    @cause = Cause.new
  end

  def edit
  end

  def create
    @cause = Cause.new params[:cause]
    @cause.funds_raised = 0
    @cause.charity_id = current_user.id
    if !@cause.save
      render 'new'
    else
      redirect_to request.referer
    end
  end

  def update
    @cause.attributes = params[:cause]
    if !@cause.save
      redirect_to request.referer
    else
      redirect_to root_url
    end
  end

  def delete
    # TODO: chequeo para ver si se puede borrar en base al estado, y si el user es admin
    # (si se hace borrado logico, se borra permanentemente o no se puede borrar)
    @cause.destroy
    if @cause.destroyed?
      redirect_to root_url
    else
      redirect_to request.referer
    end
  end

  def check_url
    @cause = Cause.find_by_url(params[:url])
    @result = 'available'
    if @cause
      @result = 'not_available'
    end
    render :text => @result
  end

  def activate
    @cause.status = :active
    @cause.save
    flash[:notice] = "Activated"
    if not request.xhr? #Not Ajax?
        redirect_to request.referer
    end
  end

  def deactivate
    @cause.status = :inactive
    @cause.save
    flash[:notice] = "Desactivated"
    if not request.xhr? #Not Ajax?
        redirect_to request.referer
    end
  end

  def mark_paid
    @cause.status = :paid
    @cause.save
    redirect_to request.referer
  end

  private

  def load_cause
    @cause = Cause.find params[:id]
  end

  def all_category(count)
    c = CauseCategory.new :name => _("All")
    c.class_eval { attr_accessor :cause_count }
    c.cause_count = count
    return c
  end

  def only_owner_or_creator
    if not (@cause.charity.id == current_user.id || current_user.is_admin_user)
      render :nothing => true, :status => :forbidden
    end
  end


end

