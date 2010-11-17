class CreateGalleryItems < ActiveRecord::Migration
  def self.up
    create_table :gallery_items do |t|
      t.integer :gallery_id
      t.integer :relative_order
      t.string :type
      t.string :video_url
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.datetime :image_updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :gallery_items
  end
end

