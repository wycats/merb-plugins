module Merb::Test::Rspec::ControllerMatchers
  include Merb::Test::ControllerHelper
  
  class BeRedirect
    def matches?(target)
      @target = target
      [307, *(300..305)].include?(target.respond_to?(:status) ? target.status : target)
    end
    def failure_message
      "expected#{inspect_target} to redirect"
    end
    def negative_failure_message
      "expected#{inspect_target} not to redirect"
    end
    
    def inspect_target
      " #{@target.controller_name}##{@target.action_name}" if @target.respond_to?(:controller_name) && @target.respond_to?(:action_name)
    end
  end
  
  class RedirectTo
    def initialize(expected)
      @expected = expected
    end
    
    def matches?(target)
      @target, @location = target, target.headers['Location']
      @redirected = BeRedirect.new.matches?(target.status)
      @location == @expected && @redirected
    end
    
    def failure_message
      msg = "expected #{inspect_target} to redirect to <#{@expected}>, but "
      if @redirected
        msg << "was <#{target_location}>" 
      else
        msg << "there was no redirection"
      end
    end
    
    def negative_failure_message
      "expected #{inspect_target} not to redirect to <#{@expected}>, but did anyway"
    end
    
    def inspect_target
      "#{@target.controller_name}##{@target.action_name}"
    end
    
    def target_location
      @target.respond_to?(:headers) ? @target.headers['Location'] : @target
    end
  end
  
  class BeSuccess
    
    def matches?(target)
      @target = target
      (200..207).include?(status_code)
    end
    
    def failure_message
      "expected#{inspect_target} to be successful but was #{status_code}"
    end
    
    def negative_failure_message
      "expected#{inspect_target} not to be successful but it was #{status_code}"
    end
    
    def inspect_target
      " #{@target.controller_name}##{@target.action_name}" if @target.respond_to?(:controller_name) && @target.respond_to?(:action_name)
    end
    
    def status_code
      @target.respond_to?(:status) ? @target.status : @target
    end
  end
  
  class BeMissing
    def matches?(target)
      @target = target
      (400..417).include?(status_code)
    end
    
    def failure_message
      "expected#{inspect_target} to be missing but was #{status_code}"
    end
    
    def negative_failure_message
      "expected#{inspect_target} not to be missing but it was #{status_code}"
    end
    
    def inspect_target
      " #{@target.controller_name}##{@target.action_name}" if @target.respond_to?(:controller_name) && @target.respond_to?(:action_name)
    end
    
    def status_code
      @target.respond_to?(:status) ? @target.status : @target
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