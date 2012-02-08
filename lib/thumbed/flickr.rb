module Thumbed
  class Flickr < Image
    include Oembed
    OEMBED_ENDPOINT = "http://www.flickr.com/services/oembed/"
    matches_to(/https?:\/\/(www\.|)?flickr\.com\/.+/)
  end
end