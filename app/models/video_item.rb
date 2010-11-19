class VideoItem < GalleryItem

 validates_presence_of :video_url
 def is_video?
    true
  end
end

