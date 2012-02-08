require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Submission do
  describe "processing" do
    shared_examples_for "successful process" do
      it "creates new logging" do
        lambda {
          @submission.perform
        }.should change(Logging, :count).by(1)
      end

      it "tracks user remote address" do
        @submission.perform.sent_from.should == @submission.sent_from
      end

      it "uses tracking publicity" do
        @submission.perform.publicity.should == @submission.tracking.publicity
      end

      it "maps logging to an occurrence" do
        @submission.perform.occurrence.url.url.should == @submission.url
      end

      it "maps logging to an user" do
        @submission.perform.user_id.should == @submission.tracking.user_id
      end
    end

    shared_examples_for "new occurrence" do
      it_should_behave_like "successful process"
      it "creates new occurrence" do
        lambda {
          @submission.perform
        }.should change(Occurrence, :count).by(1)
      end
    end

    before :each do
      @tracking = Tracking.create!(
        :channel => Factory.create(:channel),
        :user => Factory.create(:user),
        :publicity => "public"
      )
      @submission = Submission.new(
        :nick => "nick",
        :ident => "ident",
        :host => "host.name.invalid",
        :url => "http://example.org/",
        :sent_from => "127.0.0.1",
        :sent_at => Time.now,
        :tracking_id => @tracking.id
      )
    end

    describe "new url" do
      it_should_behave_like "new occurrence"

      it "creates new Url" do
        lambda {
          @submission.perform.should change(Url, :count).by(1)
        }
      end

      it "adds new job to queue" do
        lambda {
          @submission.perform
        }.should change(Delayed::Job, :count).by(1)
      end
    end

    describe "existing url" do
      before :each do
        Url.create!(:url => @submission.url, :status => "checked")
      end

      it_should_behave_like "new occurrence"

      it "doesn't create new Url" do
        lambda {
          @submission.perform.should_not change(Url, :count)
        }
      end
    end

    describe "conflicting occurrence from other user" do
      before :each do
        time_travel_to(1.minutes.ago) do
          s = @submission.clone
          s.send(:instance_variable_set, "@nick", "foo")
          s.perform
        end
      end

      it_should_behave_like "new occurrence"

      it "doesn't create new Url" do
        lambda {
          @submission.perform.should_not change(Url, :count)
        }
      end
    end

    describe "conflicting occurrence" do
      before :each do
        time_travel_to(8.minutes.ago) do
          s = @submission.clone
          s.perform
        end
      end

      it_should_behave_like "successful process"

      it "doesn't create new occurrence" do
        lambda {
          @submission.perform
        }.should_not change(Occurrence, :count)
      end
    end

  end

end