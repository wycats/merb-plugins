# make sure we're running inside Merb
if defined?(Merb::Plugins)
  if Merb::BootLoader.app_loaded?
    puts "Warning: The merb_datamapper gem must be loaded before the application"
  else
    require "merb/orms/data_mapper/connection"
    Merb::Orms::DataMapper.connect
    Merb::Orms::DataMapper.register_session_type
  end
  Merb::Plugins.add_rakefiles "merb/orms/data_mapper/tasks/databases"
end