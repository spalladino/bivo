class Follow < ActiveRecord::Base

  belongs_to :user
  belongs_to :cause

  validates_presence_of :user,:message => "inexistent user"
  validates_presence_of :cause,:message => "inexistent cause"

end

