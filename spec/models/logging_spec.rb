require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Logging do
  describe "publicity cache" do
    before :each do
      @occurrence = Factory.create :occurrence
    end

    it "changes private occurrence publicity when logging is public" do
      lambda {
        Logging.create!(:occurrence => @occurrence, :sent_from => "127.0.0.1", :user_id => Factory.create(:user), :publicity => "public")
      }.should change(@occurrence, :public).from(false).to(true)
    end

    it "doesn't change publicity when logging is private" do
      @occurrence.update_attribute(:public, true)
      lambda {
        Logging.create!(:occurrence => @occurrence, :sent_from => "127.0.0.1", :user_id => Factory.create(:user), :publicity => "private")
        @occurrence.reload
      }.should_not change(@occurrence, :public)
    end

  end
end