# make sure we're running inside Merb
if defined?(Merb::Plugins)
  dependency "activerecord"
  Merb::BootLoader.before_app_loads do
    require File.join(File.dirname(__FILE__) / "merb" / "orms" / "active_record" / "connection")
    Merb::Orms::ActiveRecord.connect
    Merb::Orms::ActiveRecord.register_session_type
  end
  
  Merb::Plugins.add_rakefiles(File.join(File.dirname(__FILE__) / "active_record" / "merbtasks"))
end
