class ImageUrl < MediaUrl
  def cached?
    self.url_image && File.exists?(self.url_image.image.path(:original))
  end
end
