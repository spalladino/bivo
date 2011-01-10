class PhotoItem < GalleryItem

  validates_presence_of :image_file_name, :image_updated_at, :image_file_size, :image_content_type
  validates_attachment_size :image, :less_than => 1.megabytes
  validates_attachment_content_type :image, :content_type => ['image/jpeg', 'image/png', 'image/pjpeg']

  def is_photo?
    true
  end

  has_attached_file :image, :styles => {:thumbnail => "69x57>", :normal => "311x183>", :big_avatar => "150x110>", :comments_avatar => "50x50>"},
    :convert_options => { :thumbnail => "-gravity center -extent 69x57", :normal => "-gravity center -extent 311x183", :big_avatar => "-gravity center -extent 150x110", :comments_avatar => "-gravity center -extent 50x50"}

  def thumbnail_url
    self.image.url(:thumbnail)
  end

  def big_avatar_url
    self.image.url(:big_avatar)
  end

  def comments_avatar_url
    self.image.url(:comments_avatar)
  end

  def kind
    :photo
  end
end

