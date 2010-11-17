class GalleryItem < ActiveRecord::Base
  belongs_to :gallery

  before_create :put_relative_order


private

  def put_relative_order
    self.relative_order = (self.gallery.items.order("relative_order").last.try(:relative_order) || 0) + 1
  end

end

