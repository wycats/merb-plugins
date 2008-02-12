module Merb::Test::Rspec::ControllerMatchers
  include Merb::Test::ControllerHelper
  
  class BeRedirect
    def matches?(target)
      @target = target
      [307, *(300..305)].include?(target.respond_to?(:status) ? target.status : target)
    end
    def failure_message
      "expected#{target_message} to redirect"
    end
    def negative_failure_message
      "expected#{target_message} not to redirect"
    end
    
    def target_message
      " #{@target.inspect}" if target.respond_to?(:status)
    end
  end
  
  class RedirectTo
    def initialize(expected)
      @expected = expected
    end
    
    def matches?(target)
      @target = target.headers['Location']
      @redirected = BeRedirect.new.matches?(target.status)
      @target == @expected && @redirected
    end
    
    def failure_message
      msg = "expected a redirect to <#{@expected}>, but "
      if @redirected
        msg << "found one to <#{@target}>" 
      else
        msg << "there was no redirect"
      end
    end
    
    def negative_failure_message
      "expected not to redirect to <#{@expected}>, but did anyway"
    end
  end
  
  class BeSuccess
    
    def matches?(target)
      @target = target
      (200..207).include?(target.respond_to?(:status) ? target.status : target)
    end
    
    def failure_message
      "expected #{@target} to be successful but was #{@target.status}"
    end
    
    def negative_failure_message
      "expected #{@target} not to be successful but it was"
    end
  end
  
  class BeMissing
    def matches?(target)
      @target = target
      (400..417).include?(target.respond_to?(:status) ? target.status : target)
    end
    
    def failure_message
      "expected #{@target} to be missing but was #{@target.status}"
    end
    
    def negative_failure_message
      "expected #{@target} not to be missing but it was"
    end
  end
  
  
  def be_redirect
    BeRedirect.new
  end
  
  alias_method :redirect, :be_redirect
  
  def redirect_to(expected)
    RedirectTo.new(expected)
  end
  
  def be_success
    BeSuccess.new
  end
  
  def be_successful
    BeSuccess.new
  end
  
  def respond_successfully
    BeSuccess.new
  end
  
  def be_missing
    BeMissing.new
  end
end