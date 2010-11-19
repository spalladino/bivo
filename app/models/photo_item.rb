class PhotoItem < GalleryItem

 validates_presence_of :image_file_name, :image_updated_at, :image_file_size, :image_content_type

 def is_photo?
    true
 end

end

