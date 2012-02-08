module Thumbed
  module Oembed
    def title
      oembed(:title)
    end
    
    def content
      oembed(:url) if oembed(:type) == 'photo'
      # For video, search for html tag (general solution)
      @url
    end
    
    protected
    
    def image_url
      return oembed(:url) if oembed(:type) == 'photo'
      return oembed(:thumbnail_url) if oembed(:type) == 'video'
    end
    
    def oembed(sym)
      # Lazy load oembed
      @oembed = oembed_request(@url) unless @oembed
      @oembed[sym.to_s]
    end
    
    private
  
    def oembed_request(url)
      JSON.parse(oembed_url(url).read)
    rescue JSON::ParserError
      raise ContentNotFound
    end
  
    def oembed_url(url)
      URI.parse(self.class::OEMBED_ENDPOINT + "?url=" + URI.escape(url.to_s) + "&format=json")
    end
  end
end