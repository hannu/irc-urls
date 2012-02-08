class Nick < ActiveRecord::Base
  belongs_to                :network
  has_many                  :occurrences, :dependent => :destroy
  
  validates_presence_of     :name
  validates_format_of       :name,    :with => /^\S+$/ #Any non-whitespace character
  validates_presence_of     :network_id
  validates_presence_of     :host
  validates_format_of       :host,    :with => /^\S+$/ #Any non-whitespace character
  validates_presence_of     :ident
  validates_format_of       :ident,   :with => /^\S+$/ #Any non-whitespace character
  
  def to_param
     "#{ident.downcase}-#{host.downcase}"
   end
end
