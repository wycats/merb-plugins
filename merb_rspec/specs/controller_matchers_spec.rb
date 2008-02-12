require File.dirname(__FILE__) + '/spec_helper'

module Merb::Test::Rspec
  module ControllerMatchers
    class RedirectableTarget
      attr_accessor :status, :headers
      def initialize; @headers = {}; end
    end
    
    describe BeRedirect do
      before(:each) do
        @target = RedirectableTarget.new
      end
      
      it "should match a 301 'Moved Permanently'" do
        BeRedirect.new.matches?(301).should be_true
      end
      
      it "should match a 302 'Found'" do
        BeRedirect.new.matches?(302).should be_true
      end
      
      it "should match a 303 'See Other'" do
        BeRedirect.new.matches?(303).should be_true
      end
      
      it "should match a 304 'Not Modified'" do
        BeRedirect.new.matches?(304).should be_true
      end
      
      it "should match a 307 'Temporary Redirect'" do
        BeRedirect.new.matches?(307).should be_true
      end
      
      it "should match a target with a valid redirect code" do
        @target.status = 301
        
        BeRedirect.new.matches?(@target).should be_true
      end
      
      it "should not match a target with an unused redirect code" do
        @target.status = 399
        
        BeRedirect.new.matches?(@target).should_not be_true
      end
      
      it "should not match a target with a non redirect code" do
        @target.status = 200
        
        BeRedirect.new.matches?(@target).should_not be_true
      end
    end
    
    describe RedirectTo do
      before(:each) do
        @target = RedirectableTarget.new
      end
      
      it "should match a target if the status code is 300 level and the locations match" do
        @target.status = 301
        @target.headers['Location'] = "http://example.com/"
        
        RedirectTo.new("http://example.com/").matches?(@target).should be_true
      end
      
      it "should not match a target if the status code is not 300 level but the locations match" do
        @target.status = 404
        @target.headers['Location'] = "http://example.com/"
        
        RedirectTo.new("http://example.com/").matches?(@target).should_not be_true
      end
      
      it "should not match a target if the status code is 300 level but the locations do not match" do
        @target.status = 301
        @target.headers['Location'] = "http://merbivore.com/"
        
        RedirectTo.new("http://example.com/").matches?(@target).should_not be_true
      end
    end
    
    describe BeSuccess do
      before(:each) do
        @target = RedirectableTarget.new
      end
      
      it "should match a target with a 200 'OK' status code" do
        BeSuccess.new.matches?(200).should be_true
      end
      
      it "should match a target with a 201 'Created' status code" do
        BeSuccess.new.matches?(201).should be_true
      end
      
      it "should match a target with a 202 'Accepted' status code" do
        BeSuccess.new.matches?(202).should be_true
      end
      
      it "should match a target with a 203 'Non-Authoritative Information' status code" do
        BeSuccess.new.matches?(203).should be_true
      end
      
      it "should match a target with a 204 'No Content' status code" do
        BeSuccess.new.matches?(204).should be_true
      end
      
      it "should match a target with a 205 'Reset Content' status code" do
        BeSuccess.new.matches?(205).should be_true
      end
      
      it "should match a target with a 206 'Partial Content' status code" do
        BeSuccess.new.matches?(206).should be_true
      end
      
      it "should match a target with a 207 'Multi-Status' status code" do
        BeSuccess.new.matches?(207).should be_true
      end
      
      it "should not match a target with an unused 200 level status code" do
        BeSuccess.new.matches?(299).should_not be_true
      end
      
      it "should not match a target with a non 200 level status code" do
        BeSuccess.new.matches?(301).should_not be_true
      end
    end
    
    describe BeMissing do
      before(:each) do
        @target = RedirectableTarget.new
      end
      
      it "should match a 400 'Bad Request'" do
        BeMissing.new.matches?(400).should be_true
      end
      
      it "should match a 401 'Unauthorized'" do
        BeMissing.new.matches?(401).should be_true
      end
      
      it "should match a 403 'Forbidden'" do
        BeMissing.new.matches?(403).should be_true
      end
      
      it "should match a 404 'Not Found'" do
        BeMissing.new.matches?(404).should be_true
      end
      
      it "should match a 409 'Conflict'" do
        BeMissing.new.matches?(409).should be_true
      end
      
      it "should match a target with a valid client side error code" do
        @target.status = 404
        
        BeMissing.new.matches?(@target).should be_true
      end
      
      it "should not match a target with an unused client side error code" do
        @target.status = 499
        
        BeMissing.new.matches?(@target).should_not be_true
      end
      
      it "should not match a target with a non client side error code" do
        @target.status = 200
        
        BeMissing.new.matches?(@target).should_not be_true
      end
    end
  end
end