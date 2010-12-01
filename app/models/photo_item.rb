class PhotoItem < GalleryItem

  validates_presence_of :image_file_name, :image_updated_at, :image_file_size, :image_content_type
  validates_attachment_size :image, :less_than => 1.megabytes
  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/png']

  def is_photo?
    true
  end

  has_attached_file :image, :styles => { :thumbnail => "120x90>", :normal => "425x355>" },
    :convert_options => { :thumbnail => "-gravity center -extent 120x90", :normal => "-gravity center -extent 425x355" }
  
  def thumbnail_url
    self.image.url(:thumbnail)
  end

  def kind
    :photo
  end
end

