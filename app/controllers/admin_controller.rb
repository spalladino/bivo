class AdminController < ApplicationController
  prepend_before_filter :authenticate_user!, :only_admin

  def user_manager
    @show_options = [
      ["all", "all"],
      ["charities", "charities"],
      ["personal accounts", "personal_accounts"],
      ["active charities", "active_charities"],
      ["inactive charities", "inactive_charities"],
      ["active personal account", "active_personal_account"],
      ["inactive personal accounts", "inactive_personal_account"]
    ]

    @page_sizes = [5,10,20,50]

    @users = User.where("type <> ?", "Admin")

    @filter = params["filter"]
    @show = params["show"]

    @users = @users.where("first_name ~* ? or last_name ~* ? or charity_name ~* ?", @filter, @filter, @filter) unless @filter.blank?

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

    sort_param = params[:sort_by] || "created_at-desc"
    sort_parts = sort_param.split("-")

    @users = @users.order "#{sort_parts.first} #{sort_parts.last}"

    @per_page = (params[:per_page] || 5).to_i
    @users = @users.paginate(:per_page => @per_page, :page => params[:page])
  end

  def new_personal_user
    @resource = PersonalUser.new
    @type = @resource.type.to_sym
    @referer = request.referer
  end

  def create_personal_user
    @resource = PersonalUser.new(params["personal_user"])
    @resource.eula_accepted = true
    @referer = params[:referer]

    if (@resource.save)
      redirect_to @referer || admin_user_manager_path
    else
      @type = @resource.type.to_sym

      render "new_personal_user"
    end
  end

  def new_charity
    @resource = Charity.new
    @type = @resource.type.to_sym
    @countries = Country.all
    @categories = CharityCategory.all
    @referer = request.referer
  end

  def create_charity
    @resource = Charity.new(params["charity"])
    @resource.status = :active
    @resource.eula_accepted = true
    @type = @resource.type.to_sym
    @referer = params[:referer]

    if (@resource.save)
      redirect_to @referer || admin_user_manager_path
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
    @referer = request.referer
    @path = admin_update_user_path

    if (@type == :Charity)
      @countries = Country.all
    end

    render "users/registrations/edit"
  end

  def update_user
    @id = params[:id]
    @resource = User.find(@id)
    @type = @resource.type.to_sym
    @referer = params[:referer]
    @path = admin_update_user_path

    if (@type == :Charity)
      @countries = Country.all
    end

    if @resource.update_attributes(params[:user])
      redirect_to @referer || admin_user_manager_path
    else
      render "users/registrations/edit"
    end
  end

  def delete_user
    User.delete(params["id"]) unless params["id"].blank?
    redirect_to admin_user_manager_path
  end

  def tools
    @pending_mails = PendingMail.count
  end

  def send_mails
    MailsProcessor.instance.process
    render :text => 'done'
  end
end

