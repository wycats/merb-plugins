if defined?(Merb::Plugins)
  Merb::Plugins.config[:merb_sequel] = {}
  require "merb/orms/sequel/connection"
  Merb::Orms::Sequel.connect
  Merb::Orms::Sequel.register_session_type
  Merb::Plugins.add_rakefiles "merbtasks"
end