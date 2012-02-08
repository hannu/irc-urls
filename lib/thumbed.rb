require 'uri'
require 'open-uri'
require 'json'

module Thumbed
  SERVICES = [] unless defined?(SERVICES)

  class ThumbnailNotFound < StandardError
  end
  
  class ContentNotFound < StandardError
  end
  
  class Base
    def self.matches_to(regexp)
      Thumbed::SERVICES << [regexp, self]
    end
    
    def image?
      false
    end
    
    def video?
      false
    end
    
    def image
      @image_file ||= URI.parse(image_url).open
    rescue => e
      raise Thumbed::ThumbnailNotFound.new(e.message)
    end
    
    def content
      @content
    end
    
    def title
      @title
    end
    
    def content_type
      @content_type ||= URI.parse(content).open.content_type
    end
    
    private
    
    def image_url
      @image
    end
    
    def initialize(*args, &block)
      if args.first.is_a? Hash
        args.first.each do |key, value|
          instance_variable_set("@#{key}", value)
        end
      else
        @url = args.first.to_s
      end
    end
  end
  
  class Video < Base
    def video?
      true
    end
  end
  
  class Image < Base
    def image?
      true
    end
      
    def content_type
      @content_type ||= image.content_type
    end
  end

  # Require all modules
  require "#{File.dirname(__FILE__)}/thumbed/oembed.rb"
  Dir[File.expand_path("#{File.dirname(__FILE__)}/thumbed/*.rb")].uniq.each do |file|
    require file
  end
  
  def self.new(url)
    url = URI.parse(url) unless url.is_a?(URI)
    SERVICES.each do |v|
      begin
        return v.last.new(url) if(v.first.match url.to_s)
      rescue
        next
      end
    end
    return Generic.new(url)
  end
end