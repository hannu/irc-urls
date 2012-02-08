require 'spec_helper'

describe CachesController do
  before :all do
    @url = ImageUrl.create(
      :url => "http://example.org/lenna.png",
      :url_image => UrlImage.new(:image => File.open(File.join("spec", "fixtures", "lenna.png")))
    )
  end

  describe "as anonymous user" do
    it "should redirect to login page" do
      get :show, :id => @url.to_param
    end
  end

  describe "as logged in user" do
    before :each do
      @user = Factory.create(:user)
      sign_in @user
    end
    it "shows cached image" do
      get :show, :id => @url.to_param
    end 
  end
  
end
