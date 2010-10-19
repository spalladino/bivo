class CausesController < ApplicationController

  before_filter :authenticate_user!, :except => [ :show, :details, :index ]
  before_filter :load_cause, :except => [ :details, :index, :new, :check_url, :create ]


  before_filter :only_owner_or_admin, :only => [:delete, :edit, :update]
  before_filter :only_charity, :only => [:create]
  before_filter :only_admin, :only => [:activate, :deactivate, :mark_paid, :mark_unpaid ]

  before_filter :status_allow_edit , :only => [:edit, :update]
  before_filter :status_allow_delete, :only => [:delete]

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
    @vote = Vote.new :cause_id => params[:id], :user_id=> current_user.id
    ajax_flash[:notice] = @vote.save ? "Vote submitted" : @vote.errors.on(:cause_id)

    redirect_to request.referer unless request.xhr?
  end

  def follow
    @follow = Follow.new :cause_id => params[:id],:user_id=> current_user.id
    if @follow.save
      ajax_flash[:notice] = "Follow submitted"
    else
      ajax_flash[:notice] = "Error, try again"
    end

    redirect_to request.referer unless request.xhr?
  end

  def unfollow
    follow = Follow.find_by_cause_id_and_user_id(params[:id], current_user.id)
    follow.destroy
    if follow.destroyed?
      ajax_flash[:notice] = "Unfollow submitted"
    else
      ajax_flash[:notice] = "Error, try again"
    end

    redirect_to request.referer unless request.xhr?
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

  def destroy
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
    if @cause.save then
      ajax_flash[:notice] = "Activated"
    else
      ajax_flash[:notice] = "Error activating cause"
    end
    redirect_to request.referer unless request.xhr?
  end

  def deactivate
    @cause.status = :inactive
    @cause.save
    if @cause.save then
      ajax_flash[:notice] = "Deactivated"
    else
      ajax_flash[:notice] = "Error deactivating cause"
    end
    redirect_to request.referer unless request.xhr?
  end

  def mark_paid
    @cause.status = :paid
    @cause.save
    redirect_to request.referer
  end

  def mark_unpaid
    @cause.status = :completed
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

  def only_owner_or_admin
    if not (@cause.charity.id == current_user.id || current_user.is_admin_user)
      render :nothing => true, :status => :forbidden
    end
  end

  def only_admin
    if not current_user.is_admin_user
      render :nothing => true, :status => :forbidden
    end
  end

  def only_charity
    if not current_user.is_charity_user
      render :nothing => true, :status => :forbidden
    end
  end

  def status_allow_edit
    if !@cause.can_edit?
       render :nothing => true, :status => :forbidden
    end
  end

  def status_allow_delete
    if !current_user.is_admin_user && !@cause.can_delete?
       render :nothing => true, :status => :forbidden
    end
  end

end

