require 'rubygems'
$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')
require 'merb'
require 'merb_param_protection'
require 'merb/core_ext/class'
require 'merb/test/helper'

Spec::Runner.configure do |config|
  config.include(Merb::Test::Helper)
end

def new_controller(action = 'index', controller = nil, additional_params = {})
  request = OpenStruct.new
  request.params = {:action => action, :controller => (controller.to_s || "Test")}
  request.params.update(additional_params)
  request.cookies = {}
  request.accept ||= '*/*'
  
  yield request if block_given?
  
  response = OpenStruct.new
  response.read = ""
  (controller || Merb::Controller).build(request, response)
end

class Merb::Controller
  require 'merb/session/memory_session'
  Merb::MemorySessionContainer.setup
  include ::Merb::SessionMixin
  self.session_secret_key = "footo the bar to the baz"
end