class CreateLoggings < ActiveRecord::Migration
  def self.up
    create_table :loggings do |t|
      t.string :sent_from
      t.string :publicity
      t.belongs_to :user
      t.belongs_to :occurrence
      
      t.timestamps
    end
  end

  def self.down
    drop_table :loggings
  end
end
