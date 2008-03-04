if defined?(Merb::Plugins)
  Merb::Plugins.add_rakefiles "merb_stories" / "merbtasks"
end

# Don't include anything for RSpec if we're not in the test environment
if Merb.environment == "test"
  Merb::BootLoader.after_app_loads do
    require File.join(File.dirname(__FILE__) / "merb_stories" / "story")
  end
end