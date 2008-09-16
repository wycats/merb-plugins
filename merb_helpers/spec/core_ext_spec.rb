require File.dirname(__FILE__) + '/spec_helper'

shared_examples_for "Date, DateTime, Time formatting" do
  
  before(:each) do
    Date.reset_formats
  end
  
  it "should list the available formats" do
    Date.formats.should be_an_instance_of(Hash)
    Date.formats.keys.length.should > 1
  end

  it "should support to be db formatted" do
    @date.formatted(:db).should =~ /^2007-11-02 \d{2}:\d{2}:\d{2}$/
  end
  
  it "should support to be time formatted" do
    @date.formatted(:time).should == "00:00"
  end

  it "should support to be short formatted" do
    @date.formatted(:short).should == "02 Nov 00:00"
  end
  
  it "should support to be date formatted" do
    @date.formatted(:date).should == "2007-11-02"
  end
  
  it "should support to be long formatted" do
    @date.formatted(:long).should == "November 02, 2007 00:00"
  end
  
  it "should support a new date format" do
    @date.formatted(:matt).should == @date.to_s
    Date.add_format(:matt, "%H:%M:%S %Y-%m-%d")
    @date.formatted(:matt).should == "00:00:00 2007-11-02"
  end

end


describe "Date" do
  before :each do
    @date = Date.new(2007, 11, 02)
  end

  it "Should do to_time conversion and return a Time class" do
    @date.is_a?(Date)
    @date.to_time.is_a?(Time)
  end

  it "Should do to_time conversion to utc by default" do
    @date.to_time.to_s.should == 'Fri Nov 02 00:00:00 UTC 2007'
  end

  it "Should do to_time conversion to utc when param :utc is given" do
    @date.to_time(:utc).to_s.should == 'Fri Nov 02 00:00:00 UTC 2007'
  end

  it "Should do to_time conversion to local time when param :local is given" do
    pending("Needs to have the call to figure out the local time stubbed so this test will work no matter what your local TZ is.")
    @date.to_time(:local).to_s.should == 'Fri Nov 02 00:00:00 -0500 2007'
  end

  it "Should return itself when to_date is called" do
    @date.to_date.should == @date
  end
  
  it_should_behave_like "Date, DateTime, Time formatting"
  
end

describe "DateTime" do
  
  before(:each) do
    @date = DateTime.new(2007, 11, 02)
  end
  
  it_should_behave_like "Date, DateTime, Time formatting"
    
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
