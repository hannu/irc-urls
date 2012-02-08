require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'lib/thumbed'
require 'kconv'
require 'uri'

describe "Thumbed" do
  describe "when url is not working" do
    it "should raise exception when url is not found" do
      lambda {Thumbed.new("http://www.nonexistent.url/")}.should raise_error(Thumbed::ContentNotFound)
    end
  end

  describe "YouTube" do
    urls = {
      'http://www.youtube.com/watch?v=3E-pHMN4DyA' => '3E-pHMN4DyA',
      'http://youtube.com/watch?v=_WFp4kozlOU&feature=related' => '_WFp4kozlOU',
      'http://uk.youtube.com/watch?feature=channel&v=urzU1giqVq4' => 'urzU1giqVq4'
    }

    describe "should handle YouTube URLs" do
      before(:each) do
        @yt = mock(Thumbed::YouTube)
        Thumbed::YouTube.stub!(:new).and_return(@yt)
      end

      urls.each do |url, video_id|
        it "'#{url}'" do
          Thumbed.new(url).should be(@yt)
        end
      end
    end

    describe "handling URL" do
      describe "ID parsing" do
        urls.each do |url, video_id|
          it "'#{url}'" do
            Thumbed::YouTube.new(url).instance_variable_get("@id").should eql(video_id)
          end
        end
      end

      describe "Thumbnail URL generation" do
        urls.each do |url, video_id|
          it "'#{url}'" do
            Thumbed::YouTube.new(url).send(:image_url).should eql("http://img.youtube.com/vi/#{video_id}/default.jpg")
          end
        end
      end

      describe "SWF URL generation" do
        urls.each do |url, video_id|
          it "'#{url}'" do
            Thumbed::YouTube.new(url).content.should eql("http://www.youtube.com/v/#{video_id}")
          end
        end
      end

      describe "GData" do
        before(:each) do
          @url = "http://gdata.youtube.com/feeds/api/videos/ePXlkqkFH6s"
          u = mock(URI)
          URI.should_receive(:parse).with(@url).and_return(u)
          u.should_receive(:read).and_return(File.open(File.dirname(__FILE__) + '/../fixtures/youtube.gdata.xml').read)
          @thumbed = Thumbed::YouTube.new("http://www.youtube.com/watch?v=ePXlkqkFH6s")
        end

        it "should retrieve video titles" do
          @thumbed.title.should eql("Jimmy V on the ESPY Awards 1993")
        end

        # If this is actually used for #content, the spec should be also updated
        # "Just in case"
        it "should be able to find content SWF" do
          @thumbed.send(:gdata, :content).split("&").first.should eql(@thumbed.content)
        end
      end

      describe "invalid URL" do
        describe "unparseable IDs" do
          [
            'http://www.google.fi/',
            'http://some.domain/?v=youtube_id'
          ].each do |url|
            it "'#{url}'" do
              lambda {
                Thumbed::YouTube.new(url)
              }.should raise_error(Thumbed::ContentNotFound)
            end
          end
        end

        it "should raise an exception when GData is not found" do
          u = mock(URI)
          URI.should_receive(:parse).and_return(u)
          # YouTube XML looks like this for erroneous IDs
          u.should_receive(:read).and_return("Invalid id")

          lambda {
            Thumbed::YouTube.new("http://www.youtube.com/watch?v=ePXlkqkfH6s").title
          }.should raise_error(Thumbed::ContentNotFound)
        end
      end

    end
  end

  describe "Vimeo" do
    before(:each) do
      @id = rand(10_000_000).to_s
      @url = "http://www.vimeo.com/" + @id + "/"
      response = {
        'type' => 'video',
        'title' => 'Crisis in Burma',
        'thumbnail_url' => 'http://images.vimeo.com/66/13/43/66134395/66134395_160x120.jpg'
      }
      @vimeo = Thumbed::Vimeo.new(@url)
      @vimeo.stub!(:oembed_request).and_return(response)
    end

    it "should return thumbnail url from oEmbed response" do
      @vimeo.send(:image_url).should eql('http://images.vimeo.com/66/13/43/66134395/66134395_160x120.jpg')
    end

    it "should generate an url for swf" do
      swf = "http://vimeo.com/moogaloop.swf?clip_id=" + @id
      @vimeo.content[0...swf.length].should eql(swf)
    end

    describe "invalid url" do
      before(:each) do
        u = mock(URI)
        io = mock(StringIO)
        URI.stub!(:parse).and_return(u)
        u.stub!(:read)
        JSON.stub!(:parse).and_raise(JSON::ParserError) #URL returned wrong data
        @url = "http://www.vimeo.com/10239001111111"
      end

      it "should raise error" do
        lambda { Thumbed::Vimeo.new(@url).title}.should raise_error(Thumbed::ContentNotFound)
      end
    end
  end

  describe "Facebook Share" do
    before(:each) do
      io = File.open(File.dirname(__FILE__) + '/../fixtures/facebook.share.html')
      io.stub!(:content_type).and_return("text/html")
      io.stub!(:charset).and_return("utf-8")
      @share = Thumbed::Generic::Temporary.new(io)
    end

    it "should be able to parse video url" do
      @share.video.should_not be_empty
    end

    it "should be able to parse image url" do
      @share.image.should_not be_empty
    end

    it "should be able to parse title" do
      @share.title.should eql("What Else Is There? on Vimeo")
    end
  end

  describe "Flickr" do
    it "should return a direct image url for thumbnailing"
  end

  describe "Image files" do
  end

  describe "HTML files" do
    it "should parse image title"

    describe "Charset conversion" do
      ['utf-8', 'iso-8859-1'].each do |charset|
        it "latin1 with #{charset} header" do
          utf8 = "äöÄÖ UTF-8" #Convertable to latin1
          io = mock(StringIO)
          latin1 = Iconv.conv("iso-8859-1", "utf-8", utf8)

          utf8.should_not eql(latin1)
          Kconv.isutf8(utf8).should be_true
          io.stub!(:read).and_return(latin1)
          io.stub!(:charset).and_return(charset)
          io.stub!(:read).and_return(latin1)

          Thumbed::Generic::Temporary.new(io).instance_variable_get("@content").should eql(utf8)
        end
      end
    end
  end
end
