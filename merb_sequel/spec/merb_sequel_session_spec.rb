require File.dirname(__FILE__) + "/spec_helper"
require 'merb-core/dispatch/session/store_container'
require File.join( File.dirname(__FILE__), "..", "lib", 'merb', 'session', 'sequel_session')

describe Merb::SequelSession do

  before(:each) do 
    @session_class = Merb::SequelSession
    @session = @session_class.generate
  end

  it "should have a session_store_type class attribute" do
    @session.class.session_store_type.should == :sequel
  end
  
  it "should persist values" do
    response = request(url(:controller => :spec_controller, :action => :set))
    response.should be_successful
    response.body.should == 'value'
    response = request(url(:controller => :spec_controller, :action => :get))
    response.should be_successful
    response.body.should == 'value'
  end

end
