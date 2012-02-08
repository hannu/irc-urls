require 'digest/md5'

class IndexUrlMd5 < ActiveRecord::Migration
  def self.up
    change_table(:urls) do |t|
      t.string :md5, :default => nil, :null => true
    end

    Url.reset_column_information
    Url.find_in_batches do |url|
      url.each do |url|
        url.update_attribute(:md5, Digest::MD5.hexdigest(url.url))
      end
    end

    add_index(:urls, :md5)
  end

  def self.down
    change_table(:urls) do |t|
      t.remove :md5
    end
  end
end
