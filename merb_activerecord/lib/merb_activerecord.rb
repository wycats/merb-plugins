# make sure we're running inside Merb
if defined?(Merb::Plugins)
  dependency "activerecord"
  require File.join(File.dirname(__FILE__) / "merb" / "orms" / "active_record" / "connection")
  
  Merb::BootLoader.after_app_loads do
    Merb::Orms::ActiveRecord.connect
    Merb::Orms::ActiveRecord.register_session_type
  end
  
  Merb::Plugins.add_rakefiles(File.join(File.dirname(__FILE__) / "active_record" / "merbtasks"))
end
