require 'iconv'
require 'kconv'

module Thumbed
  module Generic
    HTML_CONTENT_TYPES = ['text/html', 'text/plain', 'application/xhtml+xml', 'text/xml', 'application/xml']
    # Download these image files
    IMAGE_CONTENT_TYPES = ['image/jpeg', 'image/gif', 'image/png']
    HTTP_HEADERS = {"User-Agent" => "Mozilla/5.0"}
    
    class Temporary
      HTML_TITLE_PATTERN = /\<title\>([^>]+)\<\/title\>/iu
      VIDEO_SRC_PATTERN = /\<link rel="video_src" href="([^"|\"]+)"/iu
      IMAGE_SRC_PATTERN = /\<link rel="image_src" href="([^"|\"]+)"/iu
      
      def title
        @content.scan(HTML_TITLE_PATTERN).pop[0] rescue nil
      end
      
      def image
        @content.scan(IMAGE_SRC_PATTERN).pop[0] rescue nil
      end
      
      def video
        @content.scan(VIDEO_SRC_PATTERN).pop[0] rescue nil
      end
      
      def initialize(url)
        @content = url.read
        unless Kconv.isutf8(@content)
          # Convert charset, fallback to latin1 if no better info is available
          charset = (url.charset == "utf-8" && "iso-8859-1") || url.charset
          @content = Iconv.conv("UTF8", charset, @content)
        end
      end
    end
        
    def self.new(url)
      io = URI.parse(url.to_s).open(HTTP_HEADERS)
      if HTML_CONTENT_TYPES.include? io.content_type
        temp = Temporary.new io
        thumb = Thumbed::Base
        thumb = Thumbed::Image if temp.image
        thumb = Thumbed::Video if temp.video

        return thumb.new(
          :content =>temp.video,
          :image => temp.image,
          :title => temp.title,
          :content_type => io.content_type
        )
      elsif IMAGE_CONTENT_TYPES.include?(io.content_type)
        # Thumbnail for image
        return Thumbed::Image.new(
          :content => url.to_s,
          :image => url.to_s,
          :title => url.to_s.split("/").last,
          :content_type => io.content_type)
      end
      return Thumbed::Base.new(
        :title => url.to_s.split("/").last,
        :content_type => io.content_type)
    #rescue OpenURI::HTTPError, URI::InvalidURIError, SocketError => e
    rescue => e 
      raise ContentNotFound.new(e.message)
    end
  end
end