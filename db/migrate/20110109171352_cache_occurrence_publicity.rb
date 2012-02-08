class CacheOccurrencePublicity < ActiveRecord::Migration
  def self.up
    change_table :occurrences do |t|
      t.boolean :public, :default => false
    end
    Occurrence.reset_column_information
    Occurrence.find_in_batches(:include => :loggings) do |occurrences|
      occurrences.each do |occurrence|
        occurrence.update_attribute(:public, occurrence.loggings.select { |l| l.publicity == "public"}.count > 0)
      end
    end
  end

  def self.down
    change_table :occurrences do |t|
      t.remove :public
    end
  end
end
