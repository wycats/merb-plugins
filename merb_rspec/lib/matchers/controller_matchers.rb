module Merb::Test::Rspec::ControllerMatchers
  class BeRedirect
    def matches?(target)
      @target = target
      [301, 302].include? target
    end
    def failure_message
      "expected to redirect"
    end
    def negative_failure_message
      "expected not to redirect"
    end
  end
  
  class Redirect
    def matches?(target)
      @target = target
      BeRedirect.new.matches?(target.status)
    end
    def failure_message
      "expected #{@target.inspect} to redirect"
    end
    def negative_failure_message
      "expected #{@target.inspect} not to redirect"
    end
  end
  
  class RedirectTo
    def initialize(expected)
      @expected = expected
    end
    
    def matches?(target)
      @target = target.headers['Location']
      @redirected = BeRedirect.new.matches?(target.status)
      @target == @expected
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
      @target = target.status
      (200..299).include?(@target)
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
      (400..499).include?(@target.status)
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
  
  def redirect
    Redirect.new
  end
  
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