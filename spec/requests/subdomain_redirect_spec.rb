require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "beta subdomain" do
  it "accepts requests to /submissions" do
    post "http://beta.irc-urls.net/submissions"
    response.should_not be_redirect
  end

  it "redirects everything else" do
    get "http://beta.irc-urls.net/urls/recent"
    response.should redirect_to("http://irc-urls.net/urls/recent")
  end
end

describe "no subdomain" do
  it "accepts requests to /submissions" do
    post "http://irc-urls.net/submissions"
    response.should_not be_redirect
  end

  it "doesn't redirect everything else" do
    get "http://irc-urls.net/urls/recent"
    response.should be_success
  end
end