require 'lib/slugify'

class Channel < ActiveRecord::Base
  include Slugify
  
  has_many                  :trackings, :dependent => :destroy
  has_many                  :occurrences, :dependent => :destroy
  has_many                  :users, :through => :trackings
  has_many                  :loggings, :through => :occurrences
  belongs_to                :network
  
  validates_uniqueness_of   :name,    :case_sensitive => false, :scope => :network_id
  validates_presence_of     :name
  validates_format_of       :name,    :with => /^[\!\&#]\S+$/
  validates_presence_of     :network_id
  
  scope :slugified, lambda { |column, str|
    if match = str.match(/^(\d+)-.+/)
      return {:conditions => ["#{self.table_name}.id = ?", match[1]]}
    end
    str = self.real_name(str)
    return {:conditions => ["LOWER(#{self.table_name}.#{column.to_s}) = ?", str.downcase]}
  }
  
  def self.real_name(str)
    # Add missing '#' (ex. "foo" => "#foo")
    str.gsub(/^([^#!&])/, '#\1')
  end
  
  def self.clean_name(str)
    str.gsub(/^#/,'')
  end
  
  def public_tracking_disabled?
    self.status == 'private'
  end
  
  def public?
    @public ||= !loggings.only_public.empty?
  end
  
  def to_param
    slugify_if_necessary(id, self.class.clean_name(name))
  end
end
