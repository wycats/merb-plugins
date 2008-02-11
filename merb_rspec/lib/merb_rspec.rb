puts "MERB_RSPEC"
puts defined?(Merb::Plugins)

if defined?(Merb::Plugins)
  Merb::Plugins.add_rakefiles "merb_rspec/merbtasks"
end

if Merb.environment == "test"
  dependency 'hpricot'
  dependency 'merb-gen'
  dependency 'merb-test'
  
  require 'spec'
  require 'spec/mocks'
  require 'spec/story'
  
  require 'matchers/controller_matchers'
  require 'matchers/markup_matchers'
  
  Merb::BootLoader.after_app_loads do
    require File.join(File.dirname(__FILE__), "merb_rspec", "story")
  end
end