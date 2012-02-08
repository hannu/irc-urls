require "lib/slugify"

class Network < ActiveRecord::Base
  include Slugify
  
  has_many                  :channels, :dependent => :destroy
  has_many                  :occurrences, :through => :channels
  has_many                  :nicks, :dependent => :destroy
  has_many                  :trackings, :through => :channels
  validates_uniqueness_of   :name,    :case_sensitive => false
  validates_presence_of     :name
  validates_format_of       :name,    :with => /^\S+$/
  
  scope :slugified, lambda { |column, str|
    if match = str.match(/^(\d+)-.+/)
      return {:conditions => ["#{self.table_name}.id = ?", match[1]]}
    end
    return {:conditions => ["LOWER(#{self.table_name}.#{column.to_s}) = ?", str.downcase]}
  }

  def to_param
    slugify_if_necessary(id, name)
  end
  
  
  def public_channels
    channels.all(:order => "#{Channel.table_name}.name ASC").select do |c|
      c.public?
    end
  end
end
