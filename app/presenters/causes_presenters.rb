module CausesPresenters
  
  class FollowButtonPresenter
    
    def initialize(cause, user)
      if user.nil?
        self.label = _("Follow (you must login first)")
        self.route = "#{cause.id}/follow"
      else
        follow = Follow.find_by_cause_id_and_user_id(cause.id,current_user.id)
        self.label = if follow then _("Unfollow") else _("Follow") end
        self.route = if follow then "#{cause.id}/unfollow" else "#{cause.id}/follow" end
      end
    end
    
    attr_accessor :label
    attr_accessor :route
    
  end
  
  class VoteButtonPresenter
    
    def initialize(cause, current_user)
      self.route = "#{cause.id}/vote"
      if current_user.nil?
        self.label = "Vote (you must login first)"
        self.disabled = false
        self.visible = true
      else
        vote = Vote.new(:cause_id => cause.id ,:user_id=> current_user.id)
        if vote.valid?
          self.label = "Vote"
          self.disabled = false
          self.visible = true
        else
          error = vote.errors.on(:cause_id)
          self.label = error
          self.errors = error
          self.disabled = true
          self.visible = vote.already_exists
        end
      end
    end
    
    attr_accessor :label
    attr_accessor :disabled
    attr_accessor :visible
    attr_accessor :route
    attr_accessor :errors
  end
  
end