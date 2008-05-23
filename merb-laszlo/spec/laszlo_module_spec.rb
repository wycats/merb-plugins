require File.dirname(__FILE__) + '/spec_helper'

describe Laszlo, "#filename" do
  before :each do
    @name = Laszlo.file_name
  end
  
  it "returns a string filename" do
    @name.must be_kind_of(String)
  end
  
  it "returns a non-empty filename" do
    @name.must_not be_empty
  end
end