$:.push File.join(File.dirname(__FILE__), "..", "lib")
require 'rubygems'
require 'spec'
require 'sequel'
require 'merb-core'
require 'merb-core/test'
require 'merb-core/test/helpers'
require File.join( File.dirname(__FILE__), "..", "lib", 'merb_sequel')

module Merb
  module Orms
    module Sequel
      class << self
        def connect
          ::Sequel.connect(:adapter => 'sqlite')
        end
      end
    end
  end
end

Merb.start :environment => 'test', :adapter => 'runner', :session_store => 'session'

Spec::Runner.configure do |config|
  config.include Merb::Test::RequestHelper
end

require File.join( File.dirname(__FILE__), 'spec_model')












