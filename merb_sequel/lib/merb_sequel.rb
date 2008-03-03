if defined?(Merb::Plugins)
  Merb::Plugins.config[:merb_sequel] = {}
  require File.join(File.dirname(__FILE__) / "merb" / "orms" / "sequel" / "connection")
  
  Merb::BootLoader.after_app_loads do
    Merb::Orms::Sequel.connect
    Merb::Orms::Sequel.register_session_type
  end
  
  Merb::Plugins.add_rakefiles "merb_sequel" / "merbtasks"
end