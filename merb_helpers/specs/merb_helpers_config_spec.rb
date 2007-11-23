require File.dirname(__FILE__) + '/spec_helper'
FIXTURES_DIR = File.dirname(__FILE__) + '/fixtures'
MERB_HELPERS_ROOT = File.dirname(__FILE__) + "/.."

require 'merb_helpers'

describe "loading configuration" do
  
  def unload_merb_helpers
    Merb.class_eval do
      remove_const("Helpers") if defined?(Merb::Helpers)
    end
  end
  
  def reload_merb_helpers
    unload_merb_helpers
    load(MERB_HELPERS_ROOT + "/lib/merb_helpers.rb") 
  end
  
  before :each do
    unload_merb_helpers
  end
  
  after :all do
    reload_merb_helpers
  end
  
  it "should not have any helper available now" do
    unload_merb_helpers
    defined?(Merb::Helpers).should be_nil    
  end
  
  it "should load reload_merb_helpers" do
    unload_merb_helpers
    reload_merb_helpers
    defined?(Merb::Helpers).should_not be_nil    
  end
  
  it "should look in the merb_helpers directory for all *_helpers.rb files" do
    reload_merb_helpers
    Dir.should_receive(:[]).with("#{Merb::Helpers::HELPERS_DIR}/*_helpers.rb")
    reload_merb_helpers
  end
  
  it "should load all helpers by default" do
    reload_merb_helpers
    defined?(Merb::Helpers).should_not be_nil
    defined?(Merb::Helpers::Form).should_not be_nil
  end
  
  it "should require only the specified helpers" do
    Merb::Plugins.stub!(:config).and_return(YAML.load(File.read(FIXTURES_DIR + "/plugins_with.yml"))) 
    reload_merb_helpers   
    defined?(Merb::Helpers).should_not be_nil
    defined?(Merb::Helpers::Form).should be_nil
    defined?(Merb::Helpers::DateAndTime).should_not be_nil
  end
  
  it "should exclude the specified helpers" do
    Merb::Plugins.stub!(:config).and_return(YAML.load(File.read(FIXTURES_DIR + "/plugins_without.yml")))
    reload_merb_helpers
    defined?(Merb::Helpers).should_not be_nil
    defined?(Merb::Helpers::Form).should_not be_nil
    defined?(Merb::Helpers::DateAndTime).should be_nil
  end
  
  it "should load all helpers by default" do
    Merb::Plugins.should_receive(:config).and_return({})
    reload_merb_helpers
    defined?(Merb::Helpers).should_not be_nil
    defined?(Merb::Helpers::DateAndTime).should_not  be_nil
    defined?(Merb::Helpers::Form)
  end
  
  it "should raise an error if :with and :without are both configured" do
    Merb::Plugins.stub!(:config).and_return(:merb_helpers => {:with => "form_helpers", :without => "date_format_helpers"})
    lambda do 
      reload_merb_helpers
    end.should raise_error
    
  end
  
end