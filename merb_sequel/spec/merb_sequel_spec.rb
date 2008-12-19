require File.dirname(__FILE__) + "/spec_helper"

describe Merb::Orms::Sequel::Connect do
  it "is loaded at plugin bootstrap" do
    defined?(Merb::Orms::Sequel::Connect).should == "constant"
  end

  it "is a merb BootLoader" do
    Merb::Orms::Sequel::Connect.superclass.should eql(Merb::BootLoader)
  end
end
