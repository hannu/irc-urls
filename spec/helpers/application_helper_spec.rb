require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper do
  describe "interval" do
    it "parses interval to integer" do
      stub!(:params).and_return({
        :interval => "1minute"
      })
      interval.should == 60.seconds
    end
    it "returns 24 hours as default interval" do
      stub!(:params).and_return({
        :interval => "foo/bar"
      })
      interval.should == 24.hours
    end
  end
end