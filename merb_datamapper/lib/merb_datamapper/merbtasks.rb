require 'fileutils'

namespace :dm do
  
  task :merb_start do
    Merb.start :adapter => 'runner',
               :environment => ENV['MERB_ENV'] || 'development'
  end
  
  namespace :db do
    desc "Perform automigration"
    task :automigrate => :merb_start do
      DataMapper::Persistence.auto_migrate!
    end
  end
  
  namespace :sessions do
    desc "Creates session migration"
    task :create => :merb_start do
      dest = File.join(Merb.root, "schema", "migrations","001_add_sessions_table.rb")
      source = File.join(File.dirname(__FILE__), "merb", "session","001_add_sessions_table.rb")
      #FileUtils.cp source, dest unless File.exists?(dest)
    end
    
    desc "Clears sessions"
    task :clear => :merb_start do
      table_name = ((Merb::Plugins.config[:datamapper] || {})[:session_table_name] || "sessions")
      #Merb::Orms::DataMapper.connect.execute("DELETE FROM #{table_name}")
    end
  end
end