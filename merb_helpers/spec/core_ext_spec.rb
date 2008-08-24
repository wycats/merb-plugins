require File.dirname(__FILE__) + '/spec_helper'

describe "Date" do
  before :each do
    @date = Date.new(2007, 11, 10)
  end

  it "Should do to_time conversion and return a Time class" do
    @date.is_a?(Date)
    @date.to_time.is_a?(Time)
  end

  it "Should do to_time conversion to utc by default" do
    @date.to_time.to_s.should == 'Sat Nov 10 00:00:00 UTC 2007'
  end

  it "Should do to_time conversion to utc when param :utc is given" do
    @date.to_time(:utc).to_s.should == 'Sat Nov 10 00:00:00 UTC 2007'
  end

  it "Should do to_time conversion to local time when param :local is given" do
    pending("Needs to have the call to figure out the local time stubbed so this test will work no matter what your local TZ is.")
    @date.to_time(:local).to_s.should == 'Sat Nov 10 00:00:00 -0500 2007'
  end

  it "Should return itself when to_date is called" do
    @date.to_date.should == @date
  end
end

describe "String" do
  before :each do
    @str = "This is a fairly long string to test with!"
  end

  it "should default to appending ..." do
    @str.truncate(5).should == "Th..."
  end

  it "should default to a length of 30" do
    @str.truncate().should == "This is a fairly long strin..."
  end

  it "should truncate to a given length with a given suffix" do
    @str.truncate(15, "--more").should == "This is a--more"
  end
end
