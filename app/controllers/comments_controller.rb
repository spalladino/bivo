class CommentsController < ApplicationController
  before_filter :load_comment, :except => [:new, :create]

  def create
    if params[:class] == "Shop"
      @object = Shop.find(params[:object_id])
    elsif params[:class] == "Charity"
      @object = Charity.find(params[:object_id])
    elsif params[:class] == "Cause"
      @object = Cause.find(params[:object_id])
    end
    @user_who_commented = @current_user
    @comment = Comment.build_from(@object, @user_who_commented.id,params[:comment]["body"])
    @comment.parent_id = params[:parent_id]
    @could_save = true
    if !@comment.save
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

  def load_comment
    @comment = Comment.find(params[:id])
  end




end

