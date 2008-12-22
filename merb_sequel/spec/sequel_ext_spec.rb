require File.dirname(__FILE__) + "/spec_helper"

describe 'Sequel::Model#new_record?' do
  it_should_behave_like "having a spec model"
  
  it "is defined" do
    SpecModel.instance_methods.should include 'new_record?'
  end
  
  it "Returns true or new model" do
    a = SpecModel.new
    a.should be_new
    a.save
    a.should_not be_new
  end
end
