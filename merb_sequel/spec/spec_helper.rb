$:.insert 0, File.join(File.dirname(__FILE__), "..", "lib")
require 'rubygems'
require 'spec'
require 'spec/mocks'
require 'sequel'
require 'merb-core'
require 'merb-core/test'
require 'merb-core/test/helpers'

require File.join( File.dirname(__FILE__), "..", "lib", 'merb_sequel')

Merb::Config.use do |c|
  c[:session_store] = 'sequel'
end

Merb.start :environment => 'test', :adapter => 'runner', :session_store => 'sequel', :merb_root => File.dirname(__FILE__)

Spec::Runner.configure do |config|
  config.include Merb::Test::RequestHelper
end

Merb::Router.prepare do
  default_routes
end

require File.join( File.dirname(__FILE__), 'spec_model')
require File.join( File.dirname(__FILE__), 'spec_controller')












