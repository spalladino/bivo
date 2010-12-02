class GalleryItem < ActiveRecord::Base
  
  validates_presence_of :gallery_id, :type

  belongs_to :gallery

  before_create :put_relative_order

  def move_up
    move :up
  end

  def move_down
    move :down
  end

  def is_video?
    false
  end

  def is_photo?
    false
  end

private

  def put_relative_order
    self.relative_order = (self.gallery.items.order("relative_order").last.try(:relative_order) || 0) + 1
  end

  def move(to)
    operator = to == :up ? '<' : '>'
    order = to == :up ? 'desc' : 'asc'

    another_element = GalleryItem.where("relative_order #{operator} ? and gallery_id = ?", self.relative_order, self.gallery_id).order("relative_order #{order}").first
    return unless another_element

    another_element.relative_order, self.relative_order = self.relative_order, another_element.relative_order
    another_element.save!
    self.save!
  end

end

