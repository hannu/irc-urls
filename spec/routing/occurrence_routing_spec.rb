require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

def it_should_route_occurrences(type, controller = nil, viewtypes = true)
  describe "#{type} urls" do
    before :each do
      @prefix = "/#{type}"
      @controller = controller || "#{type.to_s.singularize}_occurrences"
      @viewtypes = viewtypes
    end

    it_should_behave_like "routable occurrence type"
  end
end

describe "occurrence routing" do
  shared_examples_for "routable occurrence type" do
    it "routes #{@prefix}/recent to occurrences#recent" do
      { :get => "#{@prefix}/recent" }.should route_to(
        :controller => @controller,
        :action => "recent"
      )
    end

    it "routes #{@prefix}/:viewtype/recent to occurrences#top" do
      { :get => "#{@prefix}/list/recent" }.should route_to(
        :controller => @controller,
        :action => "recent",
        :viewtype => "list"
      )
    end if @viewtypes

    it "routes #{@prefix}/ to occurrences#top" do
      { :get => "#{@prefix}/" }.should route_to(
        :controller => @controller,
        :action => "index"
      )
    end

    it "routes #{@prefix}/:viewtype to occurrences#top" do
      { :get => "#{@prefix}/list" }.should route_to(
        :controller => @controller,
        :action => "index",
        :viewtype => "list"
      )
    end if @viewtypes

    it "routes #{@prefix}/top/:interval to occurrences#top" do
      { :get => "#{@prefix}/top/1day" }.should route_to(
        :controller => @controller,
        :action => "index",
        :interval => "1day"
      )
    end

    it "routes #{@prefix}/top/:interval/:viewtype to occurrences#top" do
      { :get => "#{@prefix}/top/1day/list" }.should route_to(
        :controller => @controller,
        :action => "index",
        :interval => "1day",
        :viewtype => "list"
      )
    end if @viewtypes
  end

  it_should_route_occurrences :images
  it_should_route_occurrences :media, "media_occurrences" # naming fail, controller name uses plural form
  it_should_route_occurrences :videos
  it_should_route_occurrences :urls, "occurrences", false
end

describe "route generation" do
  it "creates root url" do
    url_for(:controller => "occurrences", :host => "test.local").should == "http://test.local/"
  end

  it "creates interval url" do
    url_for(:controller => "occurrences", :interval => "1day", :host => "test.local").should == "http://test.local/urls/top/1day"
  end

  it "creates recent url" do
    url_for(:controller => "occurrences", :action => "recent", :host => "test.local").should == "http://test.local/urls/recent"
  end

  it "creates top url" do
    url_for(:controller => "video_occurrences", :action => "index", :host => "test.local").should == "http://test.local/videos"
  end

  it "creates top url with list viewtype" do
    url_for(:controller => "video_occurrences", :action => "index", :viewtype => "list", :host => "test.local").should == "http://test.local/videos/list"
  end

  it "creates top url with viewtype and interval" do
    url_for(:controller => "video_occurrences", :action => "index", :viewtype => "list", :interval => "24hour", :host => "test.local").should == "http://test.local/videos/top/24hour/list"
  end

  it "creates default resource url" do
    url_for(:controller => "video_occurrences", :host => "test.local").should == "http://test.local/videos"
  end
end