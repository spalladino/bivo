class NewsController < ApplicationController
  before_filter :load_newsable, :only => [:create,:destroy]
  before_filter :create_allowed, :only => [:create]
  before_filter :load_news, :only => [:destroy]
  before_filter :delete_allowed, :only => [:destroy]

  def create

    @news = @newsable.news.build(params[:news])
    if @news.save
      flash[:notice] = _("Successfully created news.")
    else
      flash[:notice] = _("Error creating news.")
      redirect_to request.referer
    end
  end

  def destroy
    @news.destroy
    flash[:notice] = _("Successfully destroyed news.")
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
    if !rules(@newsable).can_delete?(current_user,@newsable,@news)
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
    eval("#{newsable.class.name}::NewsRules")
  end

end

