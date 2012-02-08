class AddUrlTypeIndex < ActiveRecord::Migration
  def self.up
    add_index :urls, :type
  end

  def self.down
    remove_index :urls, :type
  end
end
