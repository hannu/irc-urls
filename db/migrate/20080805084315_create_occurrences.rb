class CreateOccurrences < ActiveRecord::Migration
  def self.up
    create_table :occurrences do |t|
      t.belongs_to :channel
      t.belongs_to :nick
      t.belongs_to :url
      t.timestamps
    end
  end

  def self.down
    drop_table :occurrences
  end
end
