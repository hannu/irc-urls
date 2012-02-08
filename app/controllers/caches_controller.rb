class CachesController < UrlsController
  before_filter :authenticate_user!
  before_filter :get_url_image
  def show
    send_file @image.path(:original), :type => @image.content_type, :disposition => 'inline'
  end

  private

  def get_url_image
    @image = @urlobj.url_image.image
    raise ActiveRecord::RecordNotFound unless @image
  end
end
