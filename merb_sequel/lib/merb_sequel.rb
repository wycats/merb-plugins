# make sure we're running inside Merb
if defined?(Merb::Plugins)
  if Merb::BootLoader.app_loaded?
    puts "Warning: The merb_sequel gem must be loaded before the application"
  else
    require "merb/orms/sequel/connection"
    Merb::Orms::Sequel.connect
    Merb::Orms::Sequel.register_session_type
  end
  
  Merb::Plugins.add_rakefiles "merbtasks"
end