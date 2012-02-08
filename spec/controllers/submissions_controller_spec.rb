require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SubmissionsController do
  before :each do
    @data = {
      :nick =>"sample-nick",
      :client_key =>"replace-with-something-sane",
      :script_version =>"1.0",
      :url =>"http://www.example.com/",
      :network => Factory.create(:network).name,
      :mask =>"test@irc.user.invalid",
      :client =>"Eggdrop",
      :channel =>"#channel"
    }
  end

  shared_examples_for "invalid submission" do
    it "doesn't submit job to queue" do
      Delayed::Job.should_not_receive(:enqueue)
      post :create, @data
    end
  end

  shared_examples_for "missing tracking" do
    it_should_behave_like "invalid submission"

    it "creates new tracking" do
      lambda {
        post :create, @data
      }.should change(Tracking, :count).by(1)
    end
  end

  shared_examples_for "existing tracking" do
    it "doesn't create new channel" do
      lambda {
        post :create, @data
      }.should_not change(Channel, :count)
    end

    it "doesn't create new tracking" do
      lambda {
        post :create, @data
      }.should_not change(Tracking, :count)
    end
  end

  describe "with invalid network" do
    before :each do
      @data.merge!(:network => "invalid-network")
    end
    it_should_behave_like "invalid submission"

    it "responds with status 404" do
      post :create, @data
      response.status.should == 404
    end
  end

  describe "with invalid parameter" do
    [:mask, :nick, :url].each do |param|
      it "rejects url if #{param} is invalid" do
        post :create, @data.merge(param => nil)
        response.should_not be_success
      end
    end
  end

  describe "with invalid session key" do
    it_should_behave_like "invalid submission"

    it "responds with status 403" do
      post :create, @data
      response.status.should == 403
    end
  end

  describe "with valid session key" do
    before :each do
      @user = Factory.create(:user)
      @data.merge!(:client_key => @user.client_key)
    end

    describe "without channel" do
      it "creates new channel" do
        lambda {
          post :create, @data
        }.should change(Channel, :count).by(1)
      end

      it_should_behave_like "missing tracking"
    end

    describe "without tracking" do
      before :each do
        Channel.create!(:network => Network.find_by_name(@data[:network]), :name => @data[:channel])
      end

      it "doesn't create new channel" do
        lambda {
          post :create, @data
        }.should_not change(Channel, :count)
      end

      it_should_behave_like "missing tracking"
    end

    shared_examples_for "successful submission" do
      it_should_behave_like "existing tracking"

      it "submits job to queue" do
        Delayed::Job.should_receive(:enqueue).once
        post :create, @data
      end

      it "responds with 200 OK" do
        post :create, @data
        response.should be_success
      end
    end

    describe "with public tracking" do
      before :each do
        Tracking.create!(
          :channel => Channel.create!(:network => Network.find_by_name(@data[:network]), :name => @data[:channel]),
          :publicity => "public",
          :user => @user
        )
      end

      it_should_behave_like "successful submission"
    end

    describe "with private tracking" do
      before :each do
        Tracking.create!(
          :channel => Channel.create!(:network => Network.find_by_name(@data[:network]), :name => @data[:channel]),
          :publicity => "private",
          :user => @user
        )
      end

      it_should_behave_like "successful submission"
    end

    describe "with blocked tracking" do
      before :each do
        Tracking.create!(
          :channel => Channel.create!(:network => Network.find_by_name(@data[:network]), :name => @data[:channel]),
          :publicity => nil,
          :user => @user
        )
      end

      it_should_behave_like "invalid submission"
      it_should_behave_like "existing tracking"
    end

  end
end
