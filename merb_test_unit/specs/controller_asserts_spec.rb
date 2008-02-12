require File.dirname(__FILE__) + '/spec_helper'

class RedirectableTarget
  attr_accessor :status, :headers
  def initialize; @headers = {}; end
end

describe Merb::Test::Unit::ControllerAsserts do
  before(:each) do
    @target = RedirectableTarget.new
  end
  
  describe "#assert_redirect" do
    it "should pass on valid redirect codes" do
      assert_redirect 301
    end
    
    it "should fail on unused redirect codes" do
      lambda{ assert_redirect(333) }.should raise_error(Test::Unit::AssertionFailedError)
    end
    
    it "should fail on non redirect codes" do
      lambda{ assert_redirect(200) }.should raise_error(Test::Unit::AssertionFailedError)
    end
    
    it "should pass a target with a valid redirect status" do
      @target.status = 301
      
      assert_redirect @target
    end
    
    it "should fail on a target with an unused redirect status" do
      @target.status = 345
      
      lambda { assert_redirect(@target) }.should raise_error(Test::Unit::AssertionFailedError)
    end
    
    it "should fail on a target with an non redirect status" do
      @target.status = 404
      
      lambda { assert_redirect(@target) }.should raise_error(Test::Unit::AssertionFailedError)
    end
  end
  
  describe "#assert_redirect_to" do
    it "should pass on a target if the status code is 300 level and the locations match" do
      @target.status = 301
      @target.headers['Location'] = "http://example.com/"
      
      assert_redirect_to "http://example.com/", @target
    end
    
    it "should fail on a target if the status code is 300 level but the locations don't match" do
      @target.status = 301
      @target.headers['Location'] = "http://example.com/"
      
      lambda { assert_redirect_to("http://localhost/", @target) }.should raise_error(Test::Unit::AssertionFailedError)
    end
    
    it "should fail on a target if the locations match but the status code is not 300 level" do
      @target.status = 200
      @target.headers['Location'] = "http://example.com/"
      
      lambda { assert_redirect_to("http://example.com/", @target) }.should raise_error(Test::Unit::AssertionFailedError)
    end
  end
  
  describe "#assert_success" do
    it "should pass on valid 200 level codes" do
      assert_success 200
    end
    
    it "should fail on unused 200 level codes" do
      lambda { assert_success 234 }.should raise_error(Test::Unit::AssertionFailedError)
    end
    
    it "should fail on non 200 level code" do
      lambda { assert_success 404 }.should raise_error(Test::Unit::AssertionFailedError)
    end
    
    it "should pass a target with a valid 200 level status" do
      @target.status = 202
      
      assert_success @target
    end
    
    it "should fail on a target with an unused 200 level status" do
      @target.status = 222
      
      lambda { assert_success(@target) }.should raise_error(Test::Unit::AssertionFailedError)
    end
    
    it "should fail on a target with an non 200 level status" do
      @target.status = 404
      
      lambda { assert_success(@target) }.should raise_error(Test::Unit::AssertionFailedError)
    end
  end
  
  describe "#assert_missing" do
    it "should pass on valid 400 level codes" do
      assert_missing 400
    end
    
    it "should fail on unused 456 level codes" do
      lambda { assert_missing 456 }.should raise_error(Test::Unit::AssertionFailedError)
    end
    
    it "should fail on non 400 level code" do
      lambda { assert_missing 301 }.should raise_error(Test::Unit::AssertionFailedError)
    end
    
    it "should pass a target with a valid 400 level status" do
      @target.status = 404
      
      assert_missing @target
    end
    
    it "should fail on a target with an unused 444 level status" do
      @target.status = 444
      
      lambda { assert_missing(@target) }.should raise_error(Test::Unit::AssertionFailedError)
    end
    
    it "should fail on a target with an non 400 level status" do
      @target.status = 200
      
      lambda { assert_missing(@target) }.should raise_error(Test::Unit::AssertionFailedError)
    end
  end
end