class News < ActiveRecord::Base
  belongs_to :newsable, :polymorphic => true

end

