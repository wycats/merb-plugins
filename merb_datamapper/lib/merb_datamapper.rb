if defined?(Merb::Plugins)
  require "merb/orms/datamapper/connection"
  Merb::Orms::DataMapper.connect
  Merb::Orms::DataMapper.register_session_type
  Merb::Plugins.add_rakefiles "merbtasks"
end