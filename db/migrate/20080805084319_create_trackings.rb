class CreateTrackings < ActiveRecord::Migration
  def self.up
    create_table :trackings do |t|
      t.string :publicity
      t.integer :is_new, :default => 0
      t.belongs_to :user
      t.belongs_to :channel
      
      t.timestamps
    end
  end

  def self.down
    drop_table :trackings
  end
end
