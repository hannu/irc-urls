class ImageOccurrencesController < OccurrencesController

  private
  
    def default_scope(scope)
      #Conditions to load only images
      scope = scope.scoped :conditions => 
        ["#{Url.table_name}.type = ?", 'ImageUrl']
    end
    
    def common_options
      @viewtype = params[:viewtype] || "grid"
      @show_view_options = true
      @media_title = "images"
      @show_navigation = true
    end
end
