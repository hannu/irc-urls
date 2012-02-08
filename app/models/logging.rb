class Logging < ActiveRecord::Base
  belongs_to                :user
  belongs_to                :occurrence
  belongs_to                :url
  
  #validates_presence_of     :user_id #Urls converted from old DB does not have user
  validates_presence_of     :occurrence_id
  
  scope :only_public, {
    :conditions => {:publicity => "public"}
  }

  after_create :update_occurrence_publicity

  # For ActiceScaffold
  def name
    created_at
  end

  private

  def update_occurrence_publicity
    occurrence.update_attribute(:public, true) if self.publicity == "public"
  end
end
