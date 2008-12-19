require "fileutils"

namespace :sequel do

  task :merb_start do
    Merb.start :adapter => 'runner',
               :environment => ENV['MERB_ENV'] || 'development'
  end

  namespace :db do

    desc "Perform migration using migrations in schema/migrations"
    task :migrate => :merb_start do
      Sequel::Migrator.apply(Sequel::Model.db, "schema/migrations", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    end

  end
  
  namespace :sessions do

    desc "Creates session migration"
    task :create => :merb_start do
      migration_exists = Dir[File.join(Merb.root,"schema", "migrations", "*.rb")].detect{ |f| f =~ /database_sessions\.rb/ }
      if migration_exists
        puts "\nThe Session Migration File already exists\n\n"
      else
        sh %{merb-gen session_migration}
      end
    end
    
    desc "Clears sessions"
    task :clear => :merb_start do
      table_name = ((Merb::Plugins.config[:sequel] || {})[:session_table_name] || "sessions")
      
      Merb::Orms::Sequel.connect.execute("DELETE FROM #{table_name}")
    end

  end

end
