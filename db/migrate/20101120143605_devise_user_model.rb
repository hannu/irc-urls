class DeviseUserModel < ActiveRecord::Migration
  def self.up
    rename_column :users, :salt, :password_salt
    User.find_all_by_email_confirmed(false).each do |u|
      u.destroy
    end
    change_table :users do |t|
      t.remove :token
      t.remove :token_expires_at
      t.confirmable
      t.recoverable
      t.rememberable
    end

    User.reset_column_information

    User.all.each do |u|
      u.confirm! if u.read_attribute(:email_confirmed)
    end

    change_table :users do |t|
      t.remove :email_confirmed
    end
  end

  def self.down
    rename_column :users, :password_salt, :salt
    change_table :users do |t|
      t.string :token
      t.boolean :email_confirmed
      t.date :token_expires_at
      t.remove :confirmation_sent_at
      t.remove :confirmation_token
      t.remove :remember_token
      t.remove :remember_created_at
      t.remove :reset_password_token
    end

    User.reset_column_information

    User.all.each do |u|
      u.update_attribute(:email_confirmed, true) if u.read_attribute(:confirmed_at)
    end

    change_table :users do |t|
      t.remove :confirmed_at
    end
  end
end
