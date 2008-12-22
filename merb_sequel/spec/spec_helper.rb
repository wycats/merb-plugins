$:.push File.join(File.dirname(__FILE__), "..", "lib")
require 'rubygems'
require 'spec'
require 'sequel'
require 'merb-core'
require 'merb-core/test'
require 'merb-core/test/helpers'
require "merb/session/sequel_session"
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

Merb.start :environment => 'test', :adapter => 'runner', :session_store => 'sequel'

Spec::Runner.configure do |config|
  config.include Merb::Test::RequestHelper
end


class SpecModel < Sequel::Model
end

class CreateSpecModel < Sequel::Migration
  def up
    create_table! :spec_models do
      primary_key :id
      text :name
    end
  end
  
  def down
    drop_table :spec_models
  end
end

describe "it has a SpecModel", :shared => true do
  before(:each) do
    CreateSpecModel.apply(SpecModel.db, :up)
  end
  
  after(:each) do
    CreateSpecModel.apply(SpecModel.db, :down)
  end
end



