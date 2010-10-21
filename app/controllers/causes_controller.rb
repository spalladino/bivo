class CausesController < ApplicationController

  before_filter :authenticate_user!, :except => [ :show, :details, :index ]
  before_filter :load_cause, :except => [ :details, :index, :new, :check_url, :create ]

  before_filter :only_owner_or_admin, :only => [:delete, :edit, :update]
  before_filter :only_charity, :only => [:create]
  before_filter :only_admin, :only => [:activate, :deactivate, :mark_paid, :mark_unpaid ]

  before_filter :status_allow_edit , :only => [:edit, :update]
  before_filter :status_allow_delete, :only => [:delete]
  before_filter :follows_exist, :only => [:unfollow]

  def show
    render 'details'
  end

  def details
    @cause = Cause.find_by_url! params[:url]
  end

  def index
    @causes = Cause.includes(:country).includes(:charity).limit(50)
    @categories = CauseCategory.sorted_by_cause_count

    def apply_filters(&block)
      @causes = block.call(@causes)
      @categories = block.call(@categories)
    end

    # Handle sorting options
    @sorting = (params[:sorting] || :alphabetically).to_sym
    @causes = @causes.order case @sorting
      when :votes then 'votes_count DESC'
      when :funds_raised then 'funds_raised DESC'
      when :funds_needed then 'funds_needed DESC'
      when :completion then 'funds_raised / funds_needed DESC'
      when :rating then 'users.rating DESC'
      when :geographical then 'countries.name ASC, causes.city ASC'
      else 'name ASC, description ASC'
    end

    # Filter by region
    @region = params[:region]
    apply_filters { |c| c.where('causes.country_id = ?', params[:region].to_i) } unless @region.blank?

    # Filter by status
    @status = params[:status] || :active
    apply_filters { |c| c.where('causes.status = ?', @status) }

    # Filter by text
    @name = params[:name]
    apply_filters { |c| c.where('causes.name = ? OR causes.description = ?', @name, @name) } unless @name.blank?

    # Count for all causes
    all_causes_count = @causes.size

    # Filter by category
    @category = params[:category]
    @causes = @causes.where('causes.cause_category_id = ?', @category.to_i) unless @category.blank?

    # Cap maximum to show to 50
    @causes = @causes[0...50]

    # Set pagination
    @per_page = (params[:per_page] || 5).to_i
    @causes = @causes.paginate(:per_page => @per_page, :page => params[:page])

    # Fill filters fields
    @regions = Country.all
    @statuses = [:active, :raising_funds, :completed]
    @categories = @categories[0...6].insert(0, all_category(all_causes_count))
    @page_sizes = [5,10,20,50]
    @sortings = causes_list_sortings_for(@status)
  end


  def vote
    @vote = Vote.new :cause_id => params[:id], :user_id=> current_user.id
    ajax_flash[:notice] = @vote.save ? "Vote submitted" : @vote.errors[:cause_id]

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
    @follow.destroy
    if @follow.destroyed?
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
      puts "Can not save"
      puts @cause.errors
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


  def follows_exist
    @follow = Follow.find_by_cause_id_and_user_id(params[:id], current_user.id)
    if not @follow
      render :nothing => true, :status => :method_not_allowed
    end
  end

  def causes_list_sortings_for(status)
    sortings = [
      [_('alphabetically'), :alphabetical],
      [_('geographically'), :geographical],
      [_('charity rating'), :rating],
      [_('funds needed'),   :funds_needed]
    ]

    case status
      when :active then
        sortings << [_('popularity'), :votes]
      when :raising_funds then
        sortings << [_('funds raised'), :funds_raised] << [_('% of completion'), :completion]
      when :completed then
        sortings << [_('funds raised'), :funds_raised]
    end

    return sortings

  end

end

