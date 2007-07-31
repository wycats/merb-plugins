require "rubygems"
require "spec"
require "merb"
require 'active_record'

class SpecInitializer
  module ClassMethods
    def recreate_database_called?
      @recreate_database_called
    end

    def recreate_database_called!
      @recreate_database_called = true
    end
  end
  extend ClassMethods

  def add_load_paths
    $LOAD_PATH << "#{dir}/dist/app/controllers"
    $LOAD_PATH << "#{dir}/dist/app/helpers"
    $LOAD_PATH << "#{dir}/dist/app/models"
    $LOAD_PATH << "#{dir}/dist/app/views"
  end

  def load_merb
    require "#{dir}/../lib/spec/merb"
  end

  def initialize_database
    database = 'rspec_on_merb_test'
    username = 'root'
    password = 'password'

    unless recreate_database_called?
      sql = "drop database if exists #{database}; create database #{database};"
      cmd = %Q|mysql -u#{username} -p#{password} -e "#{sql};"|
      raise "Failed to recreate test database" unless system(cmd)
    end

    ActiveRecord::Base.configurations['test'] = {
      :adapter => 'mysql',
      :username => username,
      :password => password,
      :database => database,
      :host => 'localhost'
    }
    ActiveRecord::Base.establish_connection('test')

    unless recreate_database_called?
      require "#{dir}/dist/schema/migrations/001_add_things_table"
      AddThingsTable.up
    end

    recreate_database_called! unless recreate_database_called?
  end

  def require_project_files
    require_files_from_directory "controllers"
    require_files_from_directory "helpers"
    require_files_from_directory "models"
    require_files_from_directory "views"
  end

  protected
  def require_files_from_directory(app_dir)
    Dir["#{dir}/dist/app/#{app_dir}/*"].each do |file|
      require file
    end
  end

  def recreate_database_called?
    self.class.recreate_database_called?
  end

  def recreate_database_called!
    self.class.recreate_database_called!
  end

  def dir
    File.dirname(__FILE__)
  end
end

initializer = SpecInitializer.new

initializer.add_load_paths
initializer.load_merb
initializer.initialize_database
initializer.require_project_files
