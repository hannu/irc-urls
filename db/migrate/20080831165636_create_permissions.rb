class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.belongs_to :user
      t.belongs_to :tracking

      t.timestamps
    end
  end

  def self.down
    drop_table :permissions
  end
end
