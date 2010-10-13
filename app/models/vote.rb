class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :cause, :counter_cache => true
  
  validates_uniqueness_of :user_id, :scope => [:cause_id],:message => "Ya votaste.."          
                                

end
