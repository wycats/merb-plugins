# make sure we're running inside Merb
if defined?(Merb::Plugins)
  if Merb::Server.app_loaded?
    puts "Warning: The merb_sequel gem should be loaded before the application"
  end
  require 'base64'
  require "merb_sequel/initialize"
  require "merb_sequel/session"
  Merb::Controller.class_eval do
    include ::Merb::SequelSessionMixin
    puts "Using Sequel database sessions"
  end
  Merb::Plugins.add_rakefiles "merb_sequel/merbtasks"
end