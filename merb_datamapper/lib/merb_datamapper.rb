if defined?(Merb::Plugins)
  Merb::BootLoader.before_app_loads do
    require File.join(File.dirname(__FILE__) / "merb" / "orms" / "data_mapper" / "connection")
    require File.join(File.dirname(__FILE__) / "merb" / "orms" / "data_mapper" / "base")
    Merb::Orms::DataMapper.connect
    Merb::Orms::DataMapper.register_session_type
  end

  Merb::Plugins.add_rakefiles "merb_datamapper" / "merbtasks"
end