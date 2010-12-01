class CommentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_entity, :unless => [:edit]
  before_filter :load_comment, :only => [:edit, :update, :destroy, :approve]
  before_filter :create_allowed , :only => [:create]
  before_filter :edit_allowed, :only=> [:edit,:update]
  before_filter :delete_allowed, :only => [:destroy]
  before_filter :appr_allowed, :only => [:approve]

  def approve
    @comment.approved = true
    if !@comment.save
      ajax_flash[:notice] = _("Comment can not be approved")
    end
  end

  def create
    @user_who_commented = @current_user
    @comment = Comment.build_from(@entity, @user_who_commented.id,params[:comment]["body"])
    @comment.parent_id = params[:parent_id]

    rules.before_add @comment

    @could_save = true
    if @comment.save
      rules.after_add @comment if rules.respond_to?(:after_add)
    else
      @could_save = false
      ajax_flash[:notice] = _("Comment text is required")
    end
  end

  def update
    @comment.body = params[:comment]["body"]
    if @comment.save
      @could_save = true
    else
      ajax_flash[:notice] = _("Comment text is required")
    end
  end

  def destroy
    @comment.destroy
  end

  def edit
  end

protected

  def load_entity
    if params[:class] == "Shop"
      @entity = Shop.find(params[:entity_id])
    elsif params[:class] == "Charity"
      @entity = Charity.find(params[:entity_id])
    elsif params[:class] == "Cause"
      @entity = Cause.find(params[:entity_id])
    end
  end

  def load_comment
    @comment = Comment.find(params[:id])
  end

  def create_allowed
    if !rules.can_add?(current_user)
      ajax_flash[:notice] = _("You can not create comments, please, sign up")
      render :nothing => true, :status => :forbidden
    end
  end

  def edit_allowed
    if !rules.can_edit?(current_user,@entity)
      ajax_flash[:notice] = _("You can not edit this comment")
      render :nothing => true, :status => :forbidden
    end
  end

  def delete_allowed
    if !rules.can_delete?(current_user,@entity,@comment)
      ajax_flash[:notice] = _("You can not delete this comment")
      render :nothing => true, :status => :forbidden
    end
  end

 def appr_allowed
    if !rules.can_approve?(current_user,@entity,@comment)
      ajax_flash[:notice] = _("You can not approve this comment")
      render :nothing => true, :status => :forbidden
    end
  end


  def rules
    eval("#{@entity.class}::CommentRules")
  end


end

