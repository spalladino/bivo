class CharitiesController < ApplicationController
  def index
    @charities = Charity.all
  end

  def new
    @charity = Charity.new
  end

  def edit
    @charity = Charity.find(params[:id])
  end

  def create
    @charity = Charity.new(params[:charity])

    if @charity.save
      redirect_to @charity, :notice => 'Charity was successfully created.'
    else
      render :action => "new"
    end
  end

  def update
    @charity = Charity.find(params[:id])

    respond_to do |format|
      if @charity.update_attributes(params[:charity])
        redirect_to @charity, :notice => 'Charity was successfully updated.'
      else
        render :action => "edit"
      end
    end
  end

  def destroy
    @charity = Charity.find(params[:id])
    @charity.destroy

    redirect_to charities_url
  end
end
