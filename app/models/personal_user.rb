class PersonalUser < User
  attr_accessible :picture, :delete_picture
  has_attached_file :picture,
    :styles => {:comments_avatar=> "50x50#"},
    :convert_options => {:comments_avatar => "-gravity center -extent 50x50"},
    :default_url => "missing.png"


  # Validaciones de Paperclip
 validates_attachment_size :picture, :less_than => 1.megabytes, :message => _('must be 1 megabyte or lower')
 validates_attachment_content_type :picture, :content_type => Bivo::Application.config.images_content_types
 before_post_process :image?

  before_validation :clear_picture

  validates_presence_of :first_name
  validates_length_of :first_name, :maximum => 255

  validates_presence_of :last_name
  validates_length_of :last_name, :maximum => 255

  validates_length_of :gender, :maximum => 255

  validates_length_of :about_me, :maximum => 255

  validates_uniqueness_of :nickname, :case_sensitive => false, :allow_blank => true

  enum_attr :status, %w(^active deleted),:nil => false

  def is_personal_user
    return true
  end

  def name
    "#{first_name} #{last_name}"
  end

  def can_add_causes?
    false
  end

  def delete_picture=(value)
    @delete_picture = !value.to_i.zero?
  end

  def delete_picture
    !!@delete_picture
  end
  alias_method :delete_picture?, :delete_picture

  def clear_picture
    self.picture = nil if delete_picture? && !picture.dirty?
  end

  def comments_avatar_url
    self.picture.url(:comments_avatar) || "/pictures/original/missing.png"
  end

  def image?
    !(picture_content_type =~ /^image.*/).nil?
  end
  
end

