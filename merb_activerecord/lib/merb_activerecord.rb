# make sure we're running inside Merb
if defined?(Merb::Plugins)
  if Merb::BootLoader.app_loaded?
    puts "Warning: The merb_active_record gem must be loaded before the application"
  else
    require "merb/orms/active_record/connection"
    Merb::Orms::ActiveRecord.connect
    Merb::Orms::ActiveRecord.register_session_type
  end
  Merb::Plugins.add_rakefiles "merb/orms/active_record/tasks/databases"
end
