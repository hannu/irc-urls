class CreateNicks < ActiveRecord::Migration
  def self.up
    create_table :nicks do |t|
      t.string :name
      t.string :ident
      t.string :host
      t.belongs_to :network
      
      t.timestamps
    end
  end

  def self.down
    drop_table :nicks
  end
end
