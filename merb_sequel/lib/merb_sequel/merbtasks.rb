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
    task :reset => :merb_start do
      Sequel::Model.db.drop_table *Sequel::Model.db.tables
      Sequel::Migrator.apply(Sequel::Model.db, "schema/migrations", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    end

    desc "Create the database according to the config from the database.yaml. Use [username,password] if you need another user to connect to DB than in config."
    task :create, :username, :password do |t,args|
      config = Merb::Orms::Sequel.config
      puts "Creating database '#{config[:database]}'"
      case config[:adapter]
      when 'postgres'
        if args.username.nil?
          `createdb -U #{config[:username]} #{config[:database]}`
        else
          `createdb -U #{args.username} -O #{config[:username]} #{config[:database]}`
        end
      when 'mysql'
        `mysqladmin -u #{config[:username]} #{config[:password] ? "-p'#{config[:password]}'" : ''} create #{config[:database]}`
      else
        raise "Adapter #{config[:adapter]} not supported for creating databases yet."
      end
    end

    desc "Drop the database for enviroment from database.yaml (postgres only). Use [username,password] if you need another user to connect to DB than in config."
    task :drop, :username, :password do |t,args|
      config = Merb::Orms::Sequel.config
      user = args.username.nil? ? config[:username]: args.username
      puts "Droping database '#{config[:database]}'"
      case config[:adapter]
      when 'postgres'
        `dropdb -U #{user} #{config[:database]}`
      else
        raise "Adapter #{config[:adapter]} not supported for dropping databases yet."
      end
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
      Sequel::Model.db.connect.execute("DELETE FROM #{table_name}")
    end

  end

end
