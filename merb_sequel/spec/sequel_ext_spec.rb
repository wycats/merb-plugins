require File.dirname(__FILE__) + "/spec_helper"

describe 'Sequel::Model#new?' do
  before(:each) do
    spec_model_up
  end
  
  after(:each) do
    spec_model_down
  end
  
  it "is defined" do
    SpecModel.instance_methods.should include 'new?'
  end
  
  it "Returns true or new model" do
    a = SpecModel.new
    a.should be_new
    a.save
    a.should_not be_new
  end
end
