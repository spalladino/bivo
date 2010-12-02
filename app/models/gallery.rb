class Gallery < ActiveRecord::Base
  has_many :items, :foreign_key => 'gallery_id', :class_name => "GalleryItem", :order => 'relative_order'
  
  
  def self.for_entity(entity)
    gallery = Gallery.find_by_entity_id_and_entity_type(entity.id, entity.class.name)
    if !gallery
      gallery = Gallery.create!(:entity_id => entity.id, :entity_type => entity.class.name)
    end
    
    gallery
  end
end

