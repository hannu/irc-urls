class UrlsController < ApplicationController
  before_filter :get_url

  rescue_from(ActiveRecord::RecordNotFound) {|e| 
    render(:file => "#{Rails.root}/public/404.html", :status => 404)
  }

  def show
    @title = @urlobj.title
  end
  
  private
    def get_url
      @urlobj = Url.find_by_md5(params[:id]) || raise(ActiveRecord::RecordNotFound)
      @occurrences = @urlobj.occurrences.only_public_and_own(!!current_user ? current_user.id : nil).all(:order => "#{Occurrence.table_name}.created_at DESC") 
    end
end
