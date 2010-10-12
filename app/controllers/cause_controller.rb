class CauseController < ApplicationController
  
  before_filter :authenticate_user!, :except => :details
  
  UserId = 1

  def details 
    @cause = Cause.find_by_url(params[:url])
  end
  
  def index
    @causes = Cause.order('votes_count DESC').paginate(:per_page => params[:per_page] || 20, :page => params[:page])
  end

  def vote
    @vote = Vote.new(params[:causeId])
    if request.xhr?
      
      #si es ajax..  json succes:bool message:string votesCount:int
      # respond to Ajax request
      
    else
      #si no es ajax, recargo la causa y redirect con la url de la causa y meto un flash[:notice] ...
      if @vote.save
        render :partial => 'cause'
      end
      
      # respond to normal request
      
    end
  end 

end


