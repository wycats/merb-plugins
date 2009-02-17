require "fileutils"

namespace :sequel do

  desc "Minimalistic Sequel environment"
  task :sequel_env do
    Merb::Orms::Sequel.connect
  end
      
  namespace :db do

    desc "Perform migration using migrations in schema/migrations"
    task :migrate => :sequel_env do
      Sequel::Migrator.apply(Sequel::Model.db, "schema/migrations", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    end

    desc "Drop all tables and perform migrations"
    task :reset => :sequel_env do
      Sequel::Model.db.drop_table *Sequel::Model.db.tables
      Sequel::Migrator.apply(Sequel::Model.db, "schema/migrations", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    end

    desc "Truncate all tables in database"
    task :truncate => :sequel_env do
      db = Sequel::Model.db 
      db << "TRUNCATE #{db.tables.join(', ')} CASCADE;"
    end
  end
  
  namespace :sessions do

    desc "Creates session migration"
    task :create => :sequel_env do
      migration_exists = Dir[File.join(Merb.root,"schema", "migrations", "*.rb")].detect{ |f| f =~ /database_sessions\.rb/ }
      if migration_exists
        puts "\nThe Session Migration File already exists\n\n"
      else
        sh %{merb-gen session_migration}
      end
    end
    
    desc "Clears sessions"
    task :clear => :sequel_env do
      table_name = ((Merb::Plugins.config[:sequel] || {})[:session_table_name] || "sessions")
      Model.db.connect.execute("DELETE FROM #{table_name}")
    end

  end

end
