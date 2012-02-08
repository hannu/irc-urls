class User < ActiveRecord::Base
  devise :database_authenticatable,
         :confirmable,
         :recoverable,
         :rememberable,
         :validatable,
         :registerable

  has_many                  :loggings # :dependent => :destroy ??!
  has_many                  :occurrences, :through => :loggings
  has_many                  :trackings, :dependent => :destroy
  has_many                  :channels, :through => :trackings
  has_many                  :permissions, :dependent => :destroy

  validates_presence_of     :login
  validates_length_of       :login, :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login, :with => /\A\w[\w\.\-_@]+\z/
  
  before_create :make_client_key

  attr_accessible :login, :name, :email, :birthdate, :country, :location, :homepage, :password, :password_confirmation

  def self.find_by_client_key(client_key)
    login, dash, secret_key = client_key.rpartition('-')
    User.find_by_login_and_secret_key(login, secret_key)
  end

  def client_key
    "#{self.login}-#{self.secret_key}"
  end

  def regenerate_client_key!
    make_client_key
    self.save!
  end

  protected

  def self.find_for_authentication(conditions)
    conditions = ["login = ? OR email = ?", conditions[authentication_keys.first], conditions[authentication_keys.first]]
    super
  end

  def make_client_key
    self.secret_key = Digest::SHA1.hexdigest("#{Time.now}--#{(1..10).map{ rand.to_s }}")
  end
end


