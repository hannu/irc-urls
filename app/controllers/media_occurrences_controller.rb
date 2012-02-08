class MediaOccurrencesController < OccurrencesController

  private
  
    def default_scope(scope)
      #Conditions to load only images and videos
      scope = scope.scoped :conditions => 
        ["#{Url.table_name}.type IN(?, ?)", 'ImageUrl', 'VideoUrl']
    end
    
    def common_options
      @viewtype = params[:viewtype] || "grid"
      @show_view_options = true
      @media_title = "media"
      @show_navigation = true
    end
end
