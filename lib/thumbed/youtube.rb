require 'rexml/document'

module Thumbed
  class YouTube < Video
    matches_to(/https?:\/\/(.+\.)?youtube\.com\/watch\?.*/)
    
    def initialize(url)
      @id = url.to_s.scan(/youtube.com\/watch\?.*v=([^&]+)/).pop.first
      raise ContentNotFound unless @id
    rescue
      raise ContentNotFound
    end
    
    def content
      "http://www.youtube.com/v/#{@id}"
    end
    
    def title
      gdata(:title)
    end
    
    private
    
    def image_url
      "http://img.youtube.com/vi/#{@id}/default.jpg"
    end
    
    def gdata(sym)
      load_gdata unless @xml
      return @xml['//media:content'].attributes['url'] if sym.to_s == "content"
      @xml[sym.to_s].text
    end
    
    def load_gdata
      @xml = REXML::Document.new(URI.parse("http://gdata.youtube.com/feeds/api/videos/#{@id}").read).root.elements
    rescue => e
      raise ContentNotFound.new(e.message)
    end
  end
end
