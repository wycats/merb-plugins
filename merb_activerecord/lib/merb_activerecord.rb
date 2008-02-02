# make sure we're running inside Merb
if defined?(Merb::Plugins)
  require "merb/orms/active_record/connection"
  Merb::Orms::ActiveRecord.connect
  Merb::Orms::ActiveRecord.register_session_type
  Merb::Plugins.add_rakefiles "merb/orms/active_record/tasks/databases"
end
