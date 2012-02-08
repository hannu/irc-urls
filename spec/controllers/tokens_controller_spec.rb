require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TokensController do
  before :each do
    @user = Factory.create(:user)
    sign_in @user
  end

  it "regenerates user token" do
    lambda {
      post "create"
      @user.reload
    }.should change(@user, :secret_key)
  end

  describe "JSON request" do
    it "renders token as JSON" do
      ["js", "json"].each do |format|
        post :create, :format => "js"
        response.body.should == @user.reload.client_key
      end
    end
  end

  describe "HTML request" do
    before :each do
      post :create, :format => "html"
    end

    it "sets flash message" do
      flash[:confirm].should_not be_blank
    end
    it "redirects to account page" do
      response.should redirect_to(account_path)
    end
  end

  describe "without session" do
    it "redirects to login page" do
      sign_out :user
      post "create"
      response.should redirect_to(user_session_url)
    end
  end
  
end
