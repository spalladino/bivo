class Gallery < ActiveRecord::Base
  has_many :items, :foreign_key => 'gallery_id', :class_name => "GalleryItem"
end

