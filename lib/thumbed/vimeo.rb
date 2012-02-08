module Thumbed
  class Vimeo < Video
    include Oembed
    matches_to(/https?:\/\/(www\.|)vimeo\.com\/\d+.*/)
    
    OEMBED_ENDPOINT = "http://www.vimeo.com/api/oembed.json"
    
    def initialize(url)
      @id = url.to_s.scan(/vimeo\.com\/(\d+)/).pop.first
      @url = url.to_s
    rescue
      raise Thumbed::ContentNotFound
    end
    
    def content
      'http://vimeo.com/moogaloop.swf?clip_id=' + @id + '&amp;server=vimeo.com&amp;show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=00ADEF&amp;fullscreen=1'
    end
  end
end
