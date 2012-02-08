require 'digest/md5'
require 'lib/thumbed'
require 'open-uri'
require 'digest'

class Url < ActiveRecord::Base
  before_validation :calculate_md5, :on => :create

  attr_protected :md5
  attr_readonly :url, :md5

  has_many                  :occurrences, :dependent => :destroy
  has_many                  :loggings, :through => :occurrences
  belongs_to                :url_image

  validates_presence_of     :url
  validates_format_of       :url, :with => /^\S+$/ #Any non-whitespace character
  validate                  :url_protocol

  def thumbnail(size = :thumb)
    url_image.image.url(size) rescue "/images/no_thumb.png" #TODO: handle better
  end
  
  
  def to_param
    Digest::MD5.hexdigest(url)
  end
  
  # For ActiceScaffold
  def name
    url
  end

  def process
    thumb = Thumbed.new(url)

    # Succesfully loaded url. Save content
    self.content_type = truncate(thumb.content_type.to_s)
    self.title = truncate(thumb.title)
    self.content = truncate(thumb.content)
    #url.last_modified = f.last_modified unless f.last_modified.blank? IMPLEMENT THIS
    self.status = "checked"
    self.last_polled = Time.now
    self.save!

    process_thumbnail(thumb) if thumb.respond_to? :image
  end

  def cached?
    false
  end

  private

  def process_thumbnail(thumb)
    self.url_image = create_thumbnail(thumb) if thumb.respond_to? :image

    self.type = 'ImageUrl' if thumb.image?
    self.type = 'VideoUrl' if thumb.video?
    self.save!
  end

  def calculate_md5
    self.md5 = Digest::MD5.hexdigest(self.url)
  end

  def set_url_error(url, message)
    # Save URL error message
    url.last_polled = Time.now
    url.status = "error"
    url.message = message
    url.save!
  end
  
  def create_thumbnail(thumb)
    io = thumb.image
    hash = Digest::MD5.hexdigest(io.read)
    UrlImage.find_by_image_hash(hash) || UrlImage.new(
      :image => io,
      :image_file_name => url.split('/').last,
      :image_hash => hash
    )
  rescue
    nil
  end

  def truncate(str)
    return str if str.blank?
    str[0..254]
  end

  def url_protocol
    errors.add(:url, 'should use HTTP(S) protocol') unless [URI::HTTP, URI::HTTPS].include?(URI.parse(url).class)
  rescue URI::InvalidURIError
    errors.add(:url, 'is not valid formatted')
  end


end
