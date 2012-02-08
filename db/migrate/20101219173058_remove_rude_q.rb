class RemoveRudeQ < ActiveRecord::Migration
  def self.up
    drop_table :rude_queues
  end

  def self.down
    create_table :rude_queues do |t|
      t.string :queue_name
      t.text :data
      t.string :token, :default => nil
      t.boolean :processed, :default => false, :null => false

      t.timestamps
    end
    add_index :rude_queues, :processed
    add_index :rude_queues, [:queue_name, :processed]
  end
end
