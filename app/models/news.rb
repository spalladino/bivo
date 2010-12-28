class News < ActiveRecord::Base
#  after_create do
#    NewsObserver.instance.after_create self
#  end  

  belongs_to :newsable, :polymorphic => true
end
