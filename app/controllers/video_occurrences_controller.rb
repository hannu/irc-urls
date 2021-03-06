class VideoOccurrencesController < OccurrencesController

  private
  
    def default_scope(scope)
      #Conditions to load only images
      scope = scope.scoped :conditions => 
        ["#{Url.table_name}.type = ?", 'VideoUrl']
    end
    
    def common_options
      @viewtype = params[:viewtype] || "grid"
      @show_view_options = true
      @media_title = "videos"
      @show_navigation = true
    end
end
