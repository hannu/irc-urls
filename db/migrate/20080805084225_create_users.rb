class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users, :force => true do |t|
      # Columns for clearance
      t.string   :email
      t.string   :encrypted_password, :limit => 128
      t.string   :salt,               :limit => 128
      t.string   :token,              :limit => 128
      t.datetime :token_expires_at
      t.boolean  :email_confirmed,    :default => false, :null => false
      
      # Other user information
      t.string :login,       :limit => 40
      t.string :name,        :limit => 100, :default => '', :null => true
      t.date :birthdate,     :default => nil, :null => true
      t.string :country,     :default => nil, :null => true
      t.string :location,    :default => nil, :null => true
      t.string :homepage,    :default => nil, :null => true
      t.string :email,       :limit => 100
      t.string :secret_key
      t.timestamps
    end
    add_index :users, :login, :unique => true
    add_index :users, [:id, :token]
    add_index :users, :email
    add_index :users, :token
  end

  def self.down
    drop_table :users
  end
end
