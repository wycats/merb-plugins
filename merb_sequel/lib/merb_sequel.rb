if defined?(Merb::Plugins)
  require "merb/orms/sequel/connection"
  Merb::Orms::Sequel.connect
  # Merb::Orms::Sequel.register_session_type
  Merb::Plugins.add_rakefiles "merbtasks"
end