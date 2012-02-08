# -*- coding: mule-utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  before :each do
    @user = Factory :user
  end

  it "should regenerate client key" do
    lambda {
      @user.regenerate_client_key!
    }.should change(@user, :secret_key)
    @user.client_key.should_not be_blank
  end
end
