class CharitiesController < ApplicationController

  before_filter :authenticate_user!, :except => [ :show, :details, :index, :check_url]
  before_filter :load_charity, :except => [ :details, :index, :new, :create, :check_url]

  before_filter :only_owner_or_admin, :only => [ :edit, :update]
  before_filter :only_admin, :only => [:activate, :deactivate, :mark_paid, :mark_unpaid, :create,:delete]


  def index
    @charities = Charity.with_cause_data.includes(:country)
    @categories = CharityCategory.sorted_by_charities_count
    
    def apply_filters(only_charities=false, &block)
      @charities = block.call(@charities)
      @categories = block.call(@categories) unless only_charities
    end
    
    # Filter by region
    @region = params[:region]
    apply_filters {|c| c.where("#{Charity.table_name}.country_id = ?", @region.to_i)} unless @region.blank?
    
    # Filter by name
    # TODO: Use full text search
    @name = params[:name]
    apply_filters do |c| 
      c.where("#{Charity.table_name}.charity_name = ? OR #{Charity.table_name}.description = ?", @name, @name)
    end unless @name.blank?
    
    # Set categories to show
    all_categ = all_category(@charities.count.size)
    @categories = @categories.first(6).to_a.insert(0, all_categ)
    
    # Filter by category
    @category = params[:category]
    apply_filters(true) do |c| 
      c.where("#{Charity.table_name}.charity_category_id = ?", @category.to_i)
    end unless @category.blank?
    
    # Sorting
    @sorting = (params[:sorting] || :alphabetically).to_sym
    @charities = @charities.order case @sorting
      when :votes         then "votes_count DESC"
      when :funds_raised  then "#{Charity.table_name}.funds_raised DESC"
      when :rating        then "#{Charity.table_name}.rating DESC"
      when :geographical  then "#{Country.table_name}.name ASC, #{Charity.table_name}.city ASC"
                          else "#{Charity.table_name}.charity_name ASC, #{Charity.table_name}.description ASC"
    end
    
    # Set pagination
    @per_page = (params[:per_page] || 10).to_i
    @charities = @charities.first(50).paginate(:per_page => @per_page, :page => params[:page])
    
    # Fill filters fields
    @regions = Country.all
    @page_sizes = [5,10,20,50]
    @sortings = [
      [_('alphabetically'), :alphabetical],
      [_('geographically'), :geographical],
      [_('rating'),         :rating      ],
      [_('funds raised'),   :funds_raised],
    ]
    
  end

  def check_url
    if Charity.find_by_short_url(params[:url])
      render :text => 'not_available'
    else 
      render :text => 'available'
    end
  end

  def show
    render 'details'
  end

  def details
    @charity = Charity.find_by_short_url! params[:url]
  end

  def activate
    @charity.status = :active
    ajax_flash[:notice] = if @charity.save then "Activated" else "Error activating cause" end 
    redirect_to request.referer unless request.xhr?
  end

  def deactivate
    @charity.status = :inactive
    
    # TODO: Use cascade update so charity save fails if any cause save fails as well
    @charity.causes.each do |cause|
      cause.status = :inactive
      cause.save
    end
    
    ajax_flash[:notice] = if @charity.save then "Deactivated" else "Error deactivating cause" end  
    redirect_to request.referer unless request.xhr?
  end

  def follow
    @follow = CharityFollow.new :charity_id => params[:id],:user_id=> current_user.id
    ajax_flash[:notice] = if @follow.save then "Follow submitted" else "Error, try again" end 

    redirect_to request.referer unless request.xhr?
  end


  def unfollow
    follow = CharityFollow.find_by_charity_id_and_user_id(params[:id], current_user.id)
    follow.destroy
    if follow.destroyed?
      ajax_flash[:notice] = "Unfollow submitted"
    else
      ajax_flash[:notice] = "Error, try again"
    end

    redirect_to request.referer unless request.xhr?
  end


 protected

  def load_charity
    @charity = Charity.find(params[:id])
  end

  def only_owner_or_admin
    if not (@charity.id == current_user.id || current_user.is_admin_user)
      render :nothing => true, :status => :forbidden
    end
  end
  
   def all_category(count)
    c = CharityCategory.new :name => _("All")
    c.class_eval { attr_accessor :charities_count }
    c.charities_count = count
    return c
  end


end

