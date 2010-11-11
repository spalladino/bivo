class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_gettext_locale
  before_filter :check_eula_accepted
  before_filter :instantiate_controller_and_action_names

  def set_gettext_locale
    #session[:locale] = 'es' # Uncomment this line to test setting an alternative locale for gettext testingzzzzz
    super
  end

  def ajax_flash
    if request.xhr?
      flash.now
    else
      flash
    end
  end

  def only_admin
    if not (current_user && current_user.is_admin_user)
      render :nothing => true, :status => :forbidden
    end
  end

  def add_comment
    if params[:class] == "Shop"
      @object = Shop.find(params[:id])
    elsif params[:class] == "Charity"
      @object = Charity.find(params[:id])
    elsif params[:class] == "Cause"
      @object = Cause.find(params[:id])
    end
    @user_who_commented = @current_user
    @comment = Comment.build_from(@object, @user_who_commented.id,params[:comment]["body"])
    @comment.subject = params[:comment][:subject]
    @comment.title = params[:comment][:title]
    if !params[:parent_id].nil?
      @comment.parent_id = params[:parent_id]
    end
    @comment.save
  end

  def edit_comment(id)
    @comment = Comment.find(id)
  end

  def update_comment(id)

  end

  def delete_comment(id)
    Comment.find(id).destroy
  end

  protected

  def check_eula_accepted
    if (user_signed_in? && !current_user.eula_accepted)
      redirect_to accept_eula_path
    end
  end

  def instantiate_controller_and_action_names
    @action_name = action_name
    @controller_name = controller_name
  end

end

