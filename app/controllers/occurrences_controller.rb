class OccurrencesController < ApplicationController
  include ERB::Util
  
  before_filter :common_options

  def recent  
    @title = "Recent#{@media_title.blank? ? " urls" : " "+@media_title}"
    
    # Common filters
    scope = filter_occurrences 
      
    # Date filter
    unless params[:date].blank?
      begin 
        @date = params[:date].to_date
      rescue
        flash.now[:error] = 'Misformatted date'
        @date = Date.today 
      end
    else
      # Default date
      @date = Date.today 
    end
    scope = scope.scoped :conditions => 
      ["DATE(#{Occurrence.table_name}.created_at) = ?", @date]
    
    @occurrences ||= scope.all(
      :order => "newest_occurrence DESC"
    ).paginate(:page => params[:page])
    
    
    render :template => "occurrences/#{@viewtype}"
  end
  
  def index
    @title = "Most popular#{@media_title.blank? ? " urls" : " "+@media_title}" 
    
    # Set default time scope
    interval = params[:interval]
    interval = "24hours" if interval.blank?
    
    @occurrences ||= filter_occurrences.time_scope(interval).all(
      :order => "count DESC, newest_occurrence DESC"
    ).paginate(:page => params[:page])
    
    
    render :template => "occurrences/#{@viewtype}"
  end
  
  private
  
    def common_options
      @viewtype = params[:viewtype] || "list"
      @show_view_options = false
      @media_title = nil
      @show_navigation = true
    end
    
    def default_scope(scope)
      scope
    end
    
    def filter_occurrences
      # Creating new scope
      scope = Occurrence.scoped({})
      
      scope = scope.scoped(
        :select => "#{Occurrence.table_name}.url_id, 
          COUNT(*) AS count,
          MAX(#{Occurrence.table_name}.created_at) AS newest_occurrence",
          #(SELECT channel_id
          #  FROM #{TopOccurrence.table_name} AS o 
          #  WHERE #{TopOccurrence.table_name}.url_id = o.url_id
          #  ORDER BY o.created_at 
          #  DESC LIMIT 1) AS channel_id",
        :joins => [:channel, {:channel => :network}, :url],
        :group => "#{Occurrence.table_name}.url_id"
      )
      
      # Controller related filters (images, videos, media)
      scope = default_scope(scope)
      
      # Show onl public and private ocurrences that user is permitted to view
      scope = if user_signed_in?
        scope.only_public_and_own(current_user.id)
      else
        scope.scoped_by_public(true)
      end
      
      # Only checked urls
      scope = scope.scoped :conditions => 
        {"#{Url.table_name}.status" => "checked"}
           
      # Channel filter
      unless params[:channel_id].blank?
        @channel = Channel.slugified(:name, params[:channel_id]).first
        scope = scope.scoped :conditions => 
          {"#{Channel.table_name}.id" => @channel}
        @title += " on #{@channel.name rescue h(Channel.real_name(params[:channel_id]))}"
      end
      
      # Network filter
      unless params[:network_id].blank?
        @network = Network.slugified(:name, params[:network_id]).first
        scope = scope.scoped :conditions => 
          {"#{Network.table_name}.id" => @network}
        @title += " at #{@network.name rescue h(Network.real_name(params[:network_id]))}"
      end      
      
      # Search filter
      unless params[:search].blank?
        scope = scope.scoped :conditions => 
          ["(LOWER(#{Url.table_name}.title) LIKE ? OR LOWER(#{Url.table_name}.url) LIKE ?)", 
            "%#{params[:search].downcase}%",
            "%#{params[:search].downcase}%"]
        @title += " with search '#{h(params[:search])}'"
      end
      
      # URL filter
      # NOTE: We do not use this anywhere atm.
      #unless params[:url_id].blank?
      #  scope = scope.scoped :conditions => 
      #    {"#{Url.table_name}.id" => params[:url_id]}
      #end
      scope
    end
end
