# This is the default behavior for ActiveRecord when used
# in conjunction with ActionPack's request handling cycle.
# TODO write test
Merb::Controller.after do
  ActiveRecord::Base.clear_active_connections!
end