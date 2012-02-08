require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'digest/md5'

describe Url do

  describe 'allows valid URLs' do
    ['http://www.google.com', 
    'http://www.youtube.com/watch?v=sdUUx5FdySs', 
    'http://www.hs.fi/ulkomaat/artikkeli/Tukholman+ammuskelussa+haavoittuneilla+ei+hengenvaaraa/1135242309455',
    'http://areena.yle.fi/toista?quality=hi&id=1737864',
    'https://example.com'
    ].each do |str|
      it "'#{str}'" do
        Url.new(:url => str).should be_valid
      end
    end
  end
  
  describe 'disallows invalid URLs' do
    ['-invalid-', 
    'http://space bar.com',
    "http://tab\ttab.com",
    'ssh://foo@bar.lol'
    ].each do |str|
      it "'#{str}'" do
        Url.new(:url => str).should_not be_valid
      end
    end
  end

  describe "md5" do
    it "should calculate MD5 digest" do
      url = Url.create!(:url => "http://www.irc-urls.net")
      url.md5.should == Digest::MD5.hexdigest(url.url)
    end
  end

  describe "processing" do
    before :each do
      @url = Url.create(:url => "http://example.com", :status => "unchecked")
    end

    shared_examples_for "successful URL" do
      it "marks url as checked" do
        lambda {
          @url.process
        }.should change(@url, :status).to("checked")
      end

      it "sets last polled timestamp" do
        @url.process
        @url.last_polled.to_i.should be_within(2).of(Time.now.to_i)
      end

      it "saves title" do
        lambda {
          @url.process
        }.should change(@url, :title)
      end
    end

    describe "video URL" do
      before :each do
        stub_request(:get, "example.com").to_return(:body => File.read(File.join(Rails.root, "spec", "fixtures", "facebook.share.html")), :headers => {"Content-Type" => "text/html"})
      end

      it_should_behave_like "successful URL"

      it "sets url type to video" do
        @url.process
        Url.find(@url.id).should be_an_instance_of VideoUrl
      end

      it "has an thumbnail" do
        @url.process
        @url.thumbnail.should_not be_nil
      end
    end

    describe "html page" do
      before :each do
        stub_request(:get, "example.com").to_return(:body => File.read(File.join(Rails.root, "spec", "fixtures", "pages", "html_page.html")), :headers => {"Content-Type" => "text/html"})
      end

      it_should_behave_like "successful URL"

      it "doesn't create thumbnail" do
        lambda {
          @url.process
        }.should_not change(UrlImage, :count)
      end
    end
  end

  describe "cache detection" do
    before :each do
      @url = ImageUrl.new(
        :url => "http://example.com/lenna.png",
        :url_image => UrlImage.new(:image => File.open(File.join("spec", "fixtures", "lenna.png")))
      )
    end

    it "should detect missing files" do
      @url.should_not be_cached
    end

    it "should detect existing files" do
      @url.url_image.save!
      @url.should be_cached
    end
  end

  protected
    def create_url(options = {})
      record = Url.new({:url => "http://www.google.com"}.merge(options))
      record.save
      record
    end
  
end