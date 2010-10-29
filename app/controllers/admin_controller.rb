class AdminController < ApplicationController
  prepend_before_filter :authenticate_user!, :only_admin

  def edit_user
    @id = params[:id]
    @resource = User.find(params[:id])
    @resource_name = :user
    @type = @resource.type.to_sym
    @countries = Country.all

    render "users/registrations/edit_user"
  end

  def update
    @id = params[:id]
    @resource = User.find(@id)
    @resource_name = :user
    @type = @resource.type.to_sym
    @countries = Country.all

    if @resource.update_attributes(params[:user])
      redirect_to root_url
    else
      render "users/registrations/edit_user"
    end
  end
end
