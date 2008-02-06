require "fileutils"

namespace :sequel do

  namespace :db do

    desc "Perform migration using migrations in schema/migrations"
    task :migrate => :merb_init do
      Sequel::Migrator.apply(Merb::Orms::Sequel.connect, "schema/migrations", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    end

  end
  
  namespace :sessions do

    desc "Creates session migration"
    task :create => :merb_init do
      migration_exists = Dir[File.join(Merb.root,"schema", "migrations", "*.rb")].detect{ |f| f =~ /database_sessions\.rb/ }
      if migration_exists
        puts "\nThe Session Migration File already exists\n\n"
      else
        sh %{merb-gen database_sessions_migration}
      end
    end
    
    desc "Clears sessions"
    task :clear => :merb_init do
      table_name = (Merb::Plugins.config[:sequel][:session_table_name] || "sessions")
      
      Merb::Orms::Sequel.connect.execute("DELETE FROM #{table_name}")
    end

  end

end
