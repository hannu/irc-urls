class Occurrence < ActiveRecord::Base
  has_many                  :loggings, :dependent => :destroy
  has_many                  :users, :through => :loggings
  belongs_to                :channel
  belongs_to                :nick
  belongs_to                :url
  belongs_to                :network
  
  validates_presence_of     :channel_id
  validates_presence_of     :nick_id
  validates_presence_of     :url_id

  scope :recent, :order => "#{self.table_name}.created_at DESC"

  scope :only_public, lambda {
    {:conditions => ["
    #{self.table_name}.id IN 
    (SELECT occurrence_id FROM #{Logging.table_name} 
    WHERE (publicity = 'public'))"]}
  }
  
  scope :only_public_and_own, lambda { |user_id|
    {:conditions => ["
    #{self.table_name}.id IN 
    (SELECT occurrence_id FROM #{Logging.table_name} 
    WHERE (publicity = 'public') OR 
    (publicity = 'private' AND user_id = ?))", user_id]}
  }
  
  # Used to search duplicate occurrences when adding new url
  scope :posted_around, lambda { |time|
    {:conditions => ["#{self.table_name}.created_at > ? AND 
      #{self.table_name}.created_at < ?", time.utc-5.minutes, time.utc+5.minutes]}
  }
  
  scope :time_scope, lambda { |scope_str|
    return {} if scope_str == 'alltime'
    interval = scope_str.match(/(\d+)\s?(\w+)/)
    {:conditions => ["#{Occurrence.table_name}.created_at > ?", interval[1].to_i.send(interval[2]).ago]}
  }
  
  # For ActiceScaffold
  def name
    url.url
  end
end
