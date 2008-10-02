require File.dirname(__FILE__) + '/../spec_helper'

describe "merb_auth-core" do
  it "should ensure_authentication" do
    dispatch_to(Users, :index) do |controller|
      controller.should_receive(:ensure_authenticated)
    end
  end
  
  it "should have the ensure_authentication before_filter" do
    lambda { 
      dispatch_to(Users, :index) do |controller|
        controller._before_filters.flatten.should include(:ensure_authenticated)
      end
    }.should raise_error
  end
  
  it "should not ensure_authenticated when skipped" do
    dispatch_to(Dingbats, :index) do |controller|
      controller.should_not_receive(:ensure_authenticated)
    end
  end
end
