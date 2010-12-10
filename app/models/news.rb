class News < ActiveRecord::Base
  after_save do
    NewsObserver.instance.after_save self
  end  

  belongs_to :newsable, :polymorphic => true
end
