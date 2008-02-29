if defined?(Merb::Plugins)
  Merb::Plugins.add_rakefiles "merb_rspec" / "merbtasks"
end

# Don't include anything for RSpec if we're not in the test environment
if Merb.environment == "test"
  
  require 'spec'
  require 'spec/rake/spectask' if $RAKE_ENV
  require 'spec/mocks'
  require 'spec/story'
  
  module Merb::Test::Rspec
  end
  
  Merb::BootLoader.after_app_loads do
    require File.join(File.dirname(__FILE__) / "merb_rspec" / "story")
  end
end