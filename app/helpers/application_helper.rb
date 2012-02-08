# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def title(page_title)
    content_for(:title) { page_title }
    page_title
  end
  
  def js_timestamp(date)
    "<span class=\"timestamp\" title=\"#{date.to_time.utc.to_s}\">#{date.to_time.utc.to_s}</span>".html_safe
  end
  
  def create_occurrence_hash(hash)
    # Full controller path is required
    hash[:controller] = "/#{hash[:controller]}" if hash[:controller][0] != '/'[0]
    hash.each do |key, value|
      unless ['controller','action','date',
        'search','interval','viewtype','channel_id','network_id'].include?(key.to_s)
        hash.delete(key)
      end
    end
    
    # Fix action if action is not valid occurrence controller action (ex. new)
    hash[:action] = "index" unless ['recent'].include?(hash[:action].to_s)
    # Remote date if browsing most popular urls
    hash.delete(:date) if !['recent'].include?(hash[:action].to_s)
    # Fix controller if user is not in occurrence controller
    hash[:controller] = "/occurrences" unless [
      '/video_occurrences',
      '/image_occurrences',
      '/media_occurrences'].include?(hash[:controller].to_s)
    hash
  end
  
  def nice_title(url_obj)
    return url_obj.title.html_safe unless url_obj.title.blank?
    CGI.unescape(url_obj.url.split('/').last) rescue url_obj.url
  end
  
  def is_private?(url_obj)
    # Optimization for anonymous users: they can't see private urls
    # Saves 30% on front page load
    return false unless user_signed_in?
    !url_obj.loggings.collect{|l| l.publicity}.include?('public')
  end
  
  def mime_icon(url_obj)
    mime_icons = {
      /text\/plain/ => 'page_white_text.png',
      /application\/zip/ => 'page_white_compressed.png',
      /application\/x-tar/ => 'page_white_compressed.png',
      /application\/pdf/ => 'page_white_acrobat.png',
      /application\/x-shockwave-flash/ => 'page_white_flash.png',
      /video\/(.*)/ => 'film.png',
      /image\/(.*)/ => 'picture.png',
      /audio\/(.*)/ => 'music.png'
    }
    mime_icons.each do |mime,img|
      return image_tag("silk/#{img}", {:class => 'icon'}) if !url_obj.content_type.blank? && url_obj.content_type.match(mime)
    end
    "" # No mime icon
  end
  
  def typecast_flash_messages
    if ["Bad email or password."].include?(flash[:notice].to_s)
      flash.now[:error] = flash[:notice]
      flash[:notice] = nil
    end
    
    #:failure: User has not confirmed email. Confirmation email will be resent.
    unless flash[:failure].blank?
      flash.now[:error] = flash[:failure]
      flash[:failure] = nil
    end
    #:success: Confirmed email and signed in.
    unless flash[:success].blank?
      flash.now[:confirm] = flash[:success]
      flash[:success] = nil
    end
    
    #:notice: Signed in successfully.
    #:notice: You have been signed out.
    #:notice: You will receive an email within the next few minutes. It contains instructions for confirming your account.
    unless flash[:notice].blank?
      flash.now[:confirm] = flash[:notice]
      flash[:notice] = nil
    end
  end

  def analytics
    headjs("http://www.google-analytics.com/ga.js") do
      "var tracker = _gat._getTracker('UA-241252-9');tracker._trackPageview();"
    end
  end

  def interval(default = 24.hours)
    return -1 if params[:interval] == "alltime"
    match, num, unit = params[:interval].match(/(\d+)\s?(\w+)/).to_a
    num.to_i.send(unit)
  rescue
    default
  end

  def submit_button(options = {}, &block) 
    o = {:type => 'submit', :value => 'submit'}.merge(options)
    content_tag(:button, o) do yield end
  end

  def headjs(*sources, &block)
    content_tag(:script) do
      "head.js(" + (javascript_paths(*expand_javascript_sources(sources, false)).map {|s| "'#{s}'"}.join(",")) +
      if block_given?
        ",function() { #{capture(&block)} });"
      else
        ");"
      end.html_safe
    end
  end

  def javascript_paths(*sources)
    javascript_include_tag(*sources).scan(/src="([^"]+)"/).flatten
  end
end
