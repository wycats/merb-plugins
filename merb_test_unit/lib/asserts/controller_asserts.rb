module Merb::Test::Unit::ControllerAsserts
  include Test::Unit::Assertions
  include Merb::Test::ControllerHelper
    
  def assert_redirect(target)
    assert([307, *(300..305)].include?(target.respond_to?(:status) ? target.status : target), redirect_failure_message(target))
  end
  
  def assert_redirect_to(expected, target)
    location = target.headers['Location']
    
    assert_redirect(target)
    assert_equal(expected, location, redirect_to_failure_message(expected, location))
  end
  
  def assert_success(target)
    assert((200..207).include?(target.respond_to?(:status) ? target.status : target), success_failure_message(target))
  end
  
  def assert_missing(target)
    assert((400..417).include?(target.respond_to?(:status) ? target.status : target), missing_failure_message(target))
  end
  
  private
    def redirect_failure_message(target)
      "expected#{target_message(target)} to redirect"
    end
    
    def redirect_to_failure_message(expected, location)
      "expected a redirect to <#{expected}>, but found one to #{location}"
    end
    
    def success_failure_message(target)
      "expected#{target_message(target)} to be successful"
    end
    
    def missing_failure_message(target)
      "expected#{target_message(target)} to be missing"
    end
    
    def target_message(target)
      " #{@target.inspect}" if target.respond_to?(:status)
    end
end