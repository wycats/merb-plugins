$:.push File.join(File.dirname(__FILE__), "..", "lib")
require 'rubygems'
require 'spec'
require 'merb-core'
require 'merb-core/test'
require 'merb-core/test/helpers'
require File.join( File.dirname(__FILE__), "..", "lib", 'merb_sequel')

require 'sequel'
DB = Sequel.sqlite

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

def spec_model_up
  CreateSpecModel.apply(DB, :up)
end
def spec_model_down
  CreateSpecModel.apply(DB, :up)
end

class SpecModel < Sequel::Model
  set_dataset DB[:spec_models]

end
