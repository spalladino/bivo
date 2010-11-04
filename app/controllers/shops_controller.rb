class ShopsController < ApplicationController

  before_filter :authenticate_user!, :except => [:details,:home,:show]
  before_filter :only_admin, :only => [:new, :create, :edit, :update, :activate, :deactivate]
  before_filter :load_shop, :except => [ :details, :new, :create, :home, :index, :search]
  before_filter :load_places, :only => [ :new, :edit, :create, :update ]
  before_filter :load_categories, :only => [ :new, :edit, :create, :update ]

  def details
    @shop = Shop.find_by_short_url! params[:short_url]
  end

  def new
    @shop = Shop.new
  end

  def edit
  end

  def index
    @shops = Shop.all
    @count = Shop.count
        
    # Set pagination
    @per_page = (params[:per_page] || 20).to_i
    @shops = @shops.paginate(:per_page => @per_page, :page => params[:page])
    @page_sizes = [5,10,20,50]

  end

   def search
    # Filter by text
    @search_word = params[:search_word]
    if @search_word.blank?
      @shops = Shop.includes(:countries)
    else
      @shops = Shop.includes(:countries).search(@search_word)
    end

    # Handle sorting options
    @sorting = (params[:sorting] || :alphabetically).to_sym
    if @sorting == :proximity && !current_user.country_id.nil?
      @shops = @shops.where("exists (select * from country_shops where country_id = ? and shop_id = Shops.id)",current_user.country_id) + @shops.where("not exists (select * from country_shops where country_id = ? and shop_id = Shops.id)",current_user.country_id)
    else
      @shops = @shops.order 'name ASC, description ASC'
    end

    # Set pagination
    @per_page = (params[:per_page] || 20).to_i
    @shops = @shops.paginate(:per_page => @per_page, :page => params[:page])
    @page_sizes = [5,10,20,50]

    @count = @shops.count
    @sortings = [
      [_('alphabetically'), :alphabetical],
      [_('proximity'), :proximity],
    ]
  end


  def create
    @shop = Shop.new
    if save_shop
      flash[:notice] = _("Shop successfully created")
      redirect_to root_url
    else
      render :new
    end
  end

  def update
    if save_shop
      flash[:notice] = _("Shop successfully updated")
      redirect_to root_url
    else
      render :edit
    end
  end

  def home
    @shop = Shop.find_by_short_url! params[:short_url]
    if @shop.redirection == :custom_html
      redirect_to @shop.affiliate_code
    end
  end

  def show
    render 'details'
  end

  def activate
    @shop.status = :active
    if @shop.save then
      ajax_flash[:notice] = _("Activated")
    else
      ajax_flash[:error] = _("Error activating shop")
    end
    redirect_to request.referer unless request.xhr?
  end

  def deactivate
    @shop.status = :inactive
    if @shop.save then
      ajax_flash[:notice] = _("Deactivated")
    else
      ajax_flash[:error] = _("Error deactivating shop")
    end
    redirect_to request.referer unless request.xhr?
  end

  def destroy
    #TODO: Check when a shop can be safely destroyed
    @shop.destroy
    if @shop.destroyed? then
      flash[:notice] = _("Shop has been deleted")
      redirect_to root_url
    else
      flash[:error] = _("Shop could not be deleted")
      redirect_to request.referer
    end
  end

private

  def load_places
    @countries = Country.all
  end

  def save_shop
    params[:shop] ||= {}
    params[:shop][:country_ids] ||= []
    params[:shop][:category_ids] ||= []
    @shop.attributes= params[:shop]
    @shop.save
  end

  def load_shop
    @shop = Shop.find params[:id]
  end

  def load_categories
    # TODO should query all categories is a way the view is able to render the whole tree
    @categories = ShopCategory.roots
  end
end

