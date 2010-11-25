class NewsController < ApplicationController
  before_filter :load_newsable
  before_filter :create_allowed, :only => [:create]
  before_filter :load_news, :only => [:destroy]
  before_filter :delete_allowed, :only => [:destroy]

  def create
    @news = @newsable.news.build(params[:news])
    if @news.save
      flash[:notice] = "Successfully created news."
      redirect_to request.referer
    else
      flash[:notice] = "Error creating news."
      redirect_to request.referer
    end
  end

  def destroy
    newsable_type = params[:newsable_type]
    newsable_type = "User" if newsable_type == "Charity"

    @news = News.find_by_newsable_type_and_newsable_id(newsable_type,params[:newsable_id])
    @news.destroy
  end

  private

  def find_newsable
    params.each do |name, value|
      if name =~ /(.+)_id$/
        return $1.classify.constantize.find(value)
      end
    end
    nil
  end

  def load_newsable
    @newsable = find_newsable
  end

 def load_news
    @news = News.find(params[:id])
 end

  def delete_allowed
    if !rules(@newsable).can_delete?(current_user,@news,@newsable)
      ajax_flash[:notice] = _("You can not delete this news")
      render :nothing => true, :status => :forbidden
    end
  end

  def create_allowed
    if !rules(@newsable).can_add?(current_user,@newsable.id)
      ajax_flash[:notice] = _("You can not create news")
      render :nothing => true, :status => :forbidden
    end
  end


  def rules(newsable)
    eval("#{newsable.class}::NewsRules")
  end

end

