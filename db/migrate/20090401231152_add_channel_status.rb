class AddChannelStatus < ActiveRecord::Migration
  def self.up
    change_table(:channels) do |t|
      t.string :status, :default => nil, :null => true
    end
  end

  def self.down
    change_table(:channels) do |t|
      t.remove :status
    end
  end
end
