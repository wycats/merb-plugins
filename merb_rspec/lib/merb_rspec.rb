if defined?(Merb::Plugins)
  Merb::Plugins.add_rakefiles "merb_rspec/merbtasks"
end

# Don't include anything for RSpec if we're not in the test environment
if Merb.environment == "test"
  require 'merb-core/test/fake_request'
  require 'merb-core/test/multipart_helper'
  require 'merb-core/test/request_helper'
  
  dependency 'hpricot'
  dependency 'merb-test'
  
  require 'spec'
  require 'spec/mocks'
  require 'spec/story'
  
  module Merb::Test::Rspec
  
  end
  
  require File.join(File.dirname(__FILE__), 'matchers', 'controller_matchers')
  require File.join(File.dirname(__FILE__), 'matchers', 'markup_matchers')
  
  Merb::BootLoader.after_app_loads do
    require File.join(File.dirname(__FILE__), "merb_rspec", "story")
  end
end