class CharitiesController < ApplicationController
  def index
    @charities = Charity.all
  end

  def new
    @countries = Country.all
    @charity = Charity.new
  end

  def edit
    @charity = Charity.find(params[:id])
  end

  def create
    @charity = Charity.new(params[:charity])

    if @charity.save
      render :text => "exito"      
      #redirect_to @charity, :notice => 'Charity was successfully created.'
    else
      render :text => @charity.errors.to_s
      #render :action => "new"
    end
  end

  def update
    @charity = Charity.find(params[:id])

    if @charity.update_attributes(params[:charity])
      redirect_to @charity, :notice => 'Charity was successfully updated.'
    else
      render :action => "edit"
    end
  end

  def destroy
    @charity = Charity.find(params[:id])
    @charity.destroy

    redirect_to charities_url
  end
end

