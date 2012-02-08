class CreateUrls < ActiveRecord::Migration
  def self.up
    create_table :urls do |t|
      t.string :url
      t.string :title, :default => nil
      t.string :status
      t.string :message
      t.string :content
      t.string :type
      t.timestamp :last_polled, :default => nil
      t.string :content_type, :default => nil
      t.timestamp :last_modified, :default => nil
      t.belongs_to :url_image     
      t.timestamps
    end
  end

  def self.down
    drop_table :urls
  end
end
