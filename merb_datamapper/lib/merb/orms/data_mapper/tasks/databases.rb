require 'fileutils'

namespace :dm do
  namespace :db do
    desc "Perform automigration"
    task :automigrate => :merb_env do
      DataMapper::Base.auto_migrate!
    end
  end
  
  namespace :sessions do
    desc "Creates session migration"
    task :create => :merb_env do
      dest = File.join(MERB_ROOT, "schema", "migrations","001_add_sessions_table.rb")
      source = File.join(File.dirname(__FILE__), "merb", "session","001_add_sessions_table.rb")
      #FileUtils.cp source, dest unless File.exists?(dest)
    end
    
    desc "Clears sessions"
    task :clear => :merb_env do
      table_name = (Merb::Plugins.config[:data_mapper][:session_table_name] || "sessions")
      #Merb::Orms::DataMapper.connect.execute("DELETE FROM #{table_name}")
    end
  end
end