class CreateUrlImages < ActiveRecord::Migration
  def self.up
    create_table :url_images do |t|
      t.string        :image_file_name
      t.string        :image_content_type
      t.integer       :image_file_size
      t.timestamp     :image_updated_at
      t.string        :image_hash
      t.timestamps
    end
  end

  def self.down
    drop_table :url_images
  end
end
