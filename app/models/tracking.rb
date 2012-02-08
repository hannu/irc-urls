class Tracking < ActiveRecord::Base
  belongs_to                :user
  belongs_to                :channel
  has_many                  :permissions
  
  validates_presence_of     :user_id
  validates_presence_of     :channel_id
  validates_uniqueness_of   :channel_id, :scope => :user_id
  validates_inclusion_of    :publicity, :in => ['private', 'public', nil] # nil = blocked
  validate                  :private_channel
  
  def private_channel
    # Do not allow public tracking of private channels
    if self.publicity == 'public' and self.channel.status == 'private'
      errors.add_to_base('You cannot track private channel with public publicity')
    end
  end
  
  scope :only_public, :conditions => {:publicity => 'public'}
  scope :only_private, :conditions => {:publicity => 'private'}
  scope :only_untracked, :conditions => {:publicity => nil}
  
  def public?
    (publcity == 'public')
  end
  
  def blocked?
    [nil, 'blocked'].include? publicity
  end
end
