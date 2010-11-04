class AdminController < ApplicationController
  prepend_before_filter :authenticate_user!, :only_admin
  
  def index
    @show_options = [
      ["all", "all"], 
      ["charities", "charities"], 
      ["personal accounts", "personal_accounts"], 
      ["active charities", "active_charities"],
      ["inactive charities", "inactive_charities"],
      ["active personal account", "active_personal_account"],
      ["inactive personal accounts", "inactive_personal_account"]
    ]

    @users = User.where("type <> ?", "Admin")
  end

  def search
    @show_options = [
      ["all", "all"], 
      ["charities", "charities"], 
      ["personal accounts", "personal_accounts"], 
      ["active charities", "active_charities"],
      ["inactive charities", "inactive_charities"],
      ["active personal account", "active_personal_account"],
      ["inactive personal accounts", "inactive_personal_account"]
    ]
  
    @filter = params["filter"]
    @show = params["show"]

    @users = User.where("type <> ?", "Admin")
    @users = @users.where("first_name ~* ? or last_name ~* ?", @filter, @filter) unless @filter.blank?

    if (@show == "charities")
      @users = @users.where("type = ?", "Charity")
    elsif (@show == "personal_accounts")
      @users = @users.where("type = ?", "PersonalUser")
    elsif (@show == "active_charities")
      @users = @users.where("type = ? and status = ?", "Charity", "active")
    elsif (@show == "inactive_charities")
      @users = @users.where("type = ? and status = ?", "Charity", "inactive")
    elsif (@show == "active_personal_account")
      @users = @users.where("type = ? and status = ?", "PersonalUser", "active")
    elsif (@show == "inactive_personal_account")
      @users = @users.where("type = ? and status = ?", "PersonalUser", "inactive")
    end

    render "index"
  end

  def new_personal_user
    @resource = PersonalUser.new
    @type = @resource.type.to_sym
  end

  def create_personal_user
    @resource = PersonalUser.new(params["personal_user"])
    @resource.eula_accepted = true
    @type = @resource.type.to_sym

    if (@resource.save)
      redirect_to admin_user_manager_path
    else
      render "new_personal_user"
    end
  end

  def new_charity
    @resource = Charity.new
    @type = @resource.type.to_sym
    @countries = Country.all
    @categories = CharityCategory.all
  end

  def create_charity
    @resource = Charity.new(params["charity"])
    @resource.eula_accepted = true
    @type = @resource.type.to_sym
    
    if (@resource.save)
      redirect_to admin_user_manager_path
    else
      @countries = Country.all
      @categories = CharityCategory.all
      render "new_charity"
    end
  end

  def edit_user
    @id = params[:id]
    @resource = User.find(params[:id])
    @type = @resource.type.to_sym

    if (@type == :Charity)
      @countries = Country.all
    end
    
    render "edit_user"
  end

  def update_user
    @id = params[:id]
    @resource = User.find(@id)
    @type = @resource.type.to_sym

    if (@type == :Charity)
      @countries = Country.all
    end

    if @resource.update_attributes(params[:user])
      redirect_to admin_user_manager_path
    else
      render "edit_user"
    end
  end

  def delete_user
    User.delete(params["id"]) unless params["id"].blank?
    redirect_to admin_user_manager_path
  end
end
