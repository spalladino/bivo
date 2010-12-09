class Comment < ActiveRecord::Base
  after_save do
    CommentObserver.instance.after_save self
  end
end
