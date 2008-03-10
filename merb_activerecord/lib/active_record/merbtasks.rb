namespace :db do
  
  task :merb_start do
    Merb.start :adapter => 'runner', :environment => ENV['MERB_ENV'] || 'development'
  end
  
  namespace :create do
    desc 'Create all the local databases defined in config/database.yml'
    task :all => :merb_start do
      ActiveRecord::Base.configurations.each_value do |config|
        create_local_database(config)
      end
    end
  end

  desc 'Create the local database defined in config/database.yml for the current Merb.environment'
  task :create => :merb_start do
    create_local_database(ActiveRecord::Base.configurations[Merb.environment.to_sym])
  end

  def create_local_database(config)
    # Only connect to local databases
    if config[:host] == 'localhost' || config[:host].blank?
      begin
        ActiveRecord::Base.establish_connection(config)
        ActiveRecord::Base.connection
      rescue
        case config[:adapter]
        when 'mysql'
          @charset   = ENV['CHARSET']   || 'utf8'
          @collation = ENV['COLLATION'] || 'utf8_general_ci'
          begin
            ActiveRecord::Base.establish_connection(config.merge({:database => nil}))
            ActiveRecord::Base.connection.create_database(config[:database], {:charset => (config[:database][:charset] || @charset), :collation => (config[:database][:collation] || @collation)})
            ActiveRecord::Base.establish_connection(config)
            puts "MySQL #{config[:database]} database succesfully created"
          rescue
            $stderr.puts "Couldn't create database for #{config.inspect}, charset: #{@charset}, collation: #{@collation} (if you set the charset manually, make sure you have a matching collation)"
          end
        when 'postgresql'
          `createdb "#{config[:database]}" -E utf8`
        when 'sqlite'
          `sqlite "#{config[:database]}"`
        when 'sqlite3'
          `sqlite3 "#{config[:database]}"`
        end
      else
        puts "#{config[:database]} already exists"
      end
    else
      puts "This task only creates local databases. #{config[:database]} is on a remote host."
    end
  end
  
  def drop_database(config)
    case config[:adapter]
    when 'mysql'
      ActiveRecord::Base.connection.drop_database config[:database]
    when /^sqlite/
      FileUtils.rm(File.join(RAILS_ROOT, config[:database]))
    when 'postgresql'
      ActiveRecord::Base.clear_active_connections!    
      `dropdb "#{config[:database]}"`
    end
  end
  
  def local_database?(config, &block)
    if %w( 127.0.0.1 localhost ).include?(config[:host]) || config[:host].blank?
      yield
    else
      puts "This task only modifies local databases. #{config[:database]} is on a remote host."
    end
  end

  namespace :drop do
    desc 'Drops all the local databases defined in config/database.yml'
    task :all => :merb_start do
      ActiveRecord::Base.configurations.each_value do |config|
        # Skip entries that don't have a database key
        next unless config[:database]
        # Only connect to local databases
        local_database?(config) { drop_database(config) }
      end
    end
  end

  desc 'Drops the database for the current environment (set MERB_ENV to target another environment)'
  task :drop => :merb_start do
    config = ActiveRecord::Base.configurations[Merb.environment.to_sym]
    begin
      drop_database(config)
    rescue Exception => e
      puts "#{e.inspect} - #{config['database']} might have been already dropped"
    end
  end
  
  desc "Migrate the database through scripts in schema/migrations. Target specific version with VERSION=x"
  task :migrate => :merb_start do
    config = ActiveRecord::Base.configurations[Merb.environment.to_sym]
    ActiveRecord::Base.establish_connection(config)
    ActiveRecord::Migrator.migrate("schema/migrations/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
  end

  namespace :migrate do
    desc  'Rollbacks the database one migration and re migrate up. If you want to rollback more than one step, define STEP=x'
    task :redo => [ 'db:rollback', 'db:migrate' ]

    desc 'Resets your database using your migrations for the current environment'
    task :reset => ["db:drop", "db:create", "db:migrate"]
  end
  
  desc 'Drops and recreates the database from db/schema.rb for the current environment.'
  task :reset => ['db:drop', 'db:create', 'db:schema:load']

  desc 'Rolls the schema back to the previous version. Specify the number of steps with STEP=n'
  task :rollback => :merb_start do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    version = ActiveRecord::Migrator.current_version - step
    ActiveRecord::Migrator.migrate('schema/migrations/', version)
  end
  
  desc "Raises an error if there are pending migrations"
  task :abort_if_pending_migrations => :merb_start do
    if defined? ActiveRecord
      pending_migrations = ActiveRecord::Migrator.new(:up, 'schema/migrations').pending_migrations

      if pending_migrations.any?
        puts "You have #{pending_migrations.size} pending migrations:"
        pending_migrations.each do |pending_migration|
          puts '  %4d %s' % [pending_migration.version, pending_migration.name]
        end
        abort "Run `rake db:migrate` to update your database then try again."
      end
    end
  end
  
  desc "Retrieves the charset for the current environment's database"
  task :charset => :merb_start do
    config = ActiveRecord::Base.configurations[Merb.environment.to_sym]
    case config[:adapter]
    when 'mysql'
      ActiveRecord::Base.establish_connection(config)
      puts ActiveRecord::Base.connection.charset
    else
      puts 'sorry, your database adapter is not supported yet, feel free to submit a patch'
    end
  end

  desc "Retrieves the collation for the current environment's database"
  task :collation => :merb_start do
    config = ActiveRecord::Base.configurations[Merb.environment.to_sym]
    case config[:adapter]
    when 'mysql'
      ActiveRecord::Base.establish_connection(config)
      puts ActiveRecord::Base.connection.collation
    else
      puts 'sorry, your database adapter is not supported yet, feel free to submit a patch'
    end
  end

  desc "Retrieves the current schema version number"
  task :version => :merb_start do
    puts "Current version: #{ActiveRecord::Migrator.current_version}"
  end

  namespace :fixtures do
    desc "Load fixtures into the current environment's database.  Load specific fixtures using FIXTURES=x,y"
    task :load => :merb_start do
      require 'active_record/fixtures'
      config = ActiveRecord::Base.configurations[Merb.environment.to_sym]
      ActiveRecord::Base.establish_connection(config)
      (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : Dir.glob(File.join(Merb.root, 'test', 'fixtures', '*.{yml,csv}'))).each do |fixture_file|
        Fixtures.create_fixtures('test/fixtures', File.basename(fixture_file, '.*'))
      end
    end
  end

  namespace :schema do
    desc 'Create a schema/schema.rb file that can be portably used against any DB supported by AR'
    task :dump => :merb_start do
      require 'active_record/schema_dumper'
      File.open(ENV['SCHEMA'] || "schema/schema.rb", "w") do |file|
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
      end
    end
    
    desc "Load a schema.rb file into the database"
    task :load => :merb_start do
      config = ActiveRecord::Base.configurations[Merb.environment.to_sym]
      ActiveRecord::Base.establish_connection(config)
      file = ENV['SCHEMA'] || "schema/schema.rb"
      load(file)
    end
  end

 namespace :structure do
    desc "Dump the database structure to a SQL file"
    task :dump => :merb_start do
      config = ActiveRecord::Base.configurations[Merb.environment.to_sym]
      case config[:adapter]
        when "mysql", "oci", "oracle"
          ActiveRecord::Base.establish_connection(config)
          File.open("schema/#{Merb.environment}_structure.sql", "w+") { |f| f << ActiveRecord::Base.connection.structure_dump }
        when "postgresql"
          ENV['PGHOST']     = config[:host] if config[:host]
          ENV['PGPORT']     = config[:port].to_s if config[:port]
          ENV['PGPASSWORD'] = config[:password].to_s if config[:password]
          search_path = config[:schema_search_path]
          search_path = "--schema=#{search_path}" if search_path
          `pg_dump -i -U "#{config[:username]}" -s -x -O -f schema/#{Merb.environment}_structure.sql #{search_path} #{config[:database]}`
          raise "Error dumping database" if $?.exitstatus == 1
        when "sqlite", "sqlite3"
          dbfile = config[:database] || config[:dbfile]
          `#{config[:adapter]} #{dbfile} .schema > schema/#{Merb.environment}_structure.sql`
        when "sqlserver"
          `scptxfr /s #{config[:host]} /d #{config[:database]} /I /f schema\\#{Merb.environment}_structure.sql /q /A /r`
          `scptxfr /s #{config[:host]} /d #{config[:database]} /I /F schema\ /q /A /r`
        when "firebird"
          set_firebird_env(config)
          db_string = firebird_db_string(config)
          sh "isql -a #{db_string} > schema/#{Merb.environment}_structure.sql"
        else
          raise "Task not supported by '#{config[:adapter]}'"
      end

      if ActiveRecord::Base.connection.supports_migrations?
        File.open("schema/#{Merb.environment}_structure.sql", "a") { |f| f << ActiveRecord::Base.connection.dump_schema_information }
      end
    end
  end

  namespace :test do
    
    desc "Recreate the test database from the current environment's database schema"
    task :clone => %w(db:schema:dump db:test:purge) do
      ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[:test])
      ActiveRecord::Schema.verbose = false
      Rake::Task["db:schema:load"].invoke
    end

    desc "Recreate the test databases from the development structure"
    task :clone_structure => [ "db:structure:dump", "db:test:purge" ] do
      config = ActiveRecord::Base.configurations[:test]
      case config[:adapter]
        when "mysql"
          ActiveRecord::Base.establish_connection(config)
          ActiveRecord::Base.connection.execute('SET foreign_key_checks = 0')
          IO.readlines("schema/#{Merb.environment}_structure.sql").join.split("\n\n").each do |table|
            ActiveRecord::Base.connection.execute(table)
          end
        when "postgresql"
          ENV['PGHOST']     = config[:host] if config[:host]
          ENV['PGPORT']     = config[:port].to_s if config[:port]
          ENV['PGPASSWORD'] = config[:password].to_s if config[:password]
          `psql -U "#{config[:username]}" -f schema/#{Merb.environment}_structure.sql #{config[:database]}`
        when "sqlite", "sqlite3"
          dbfile = config[:database] ||config[:dbfile]
          `#{config[:adapter]} #{dbfile} < schema/#{Merb.environment}_structure.sql`
        when "sqlserver"
          `osql -E -S #{config[:host]} -d #{config[:database]} -i schema\\#{Merb.environment}_structure.sql`
        when "oci", "oracle"
          ActiveRecord::Base.establish_connection(:test)
          IO.readlines("schema/#{Merb.environment}_structure.sql").join.split(";\n\n").each do |ddl|
            ActiveRecord::Base.connection.execute(ddl)
          end
        when "firebird"
          set_firebird_env(config)
          db_string = firebird_db_string(config)
          sh "isql -i schema/#{Merb.environment}_structure.sql #{db_string}"
        else
          raise "Task not supported by '#{config[:adapter]}'"
      end
    end
    
    desc "Empty the test database"
    task :purge => :merb_start do
      config = ActiveRecord::Base.configurations[:test]
      case config[:adapter]
        when "mysql"
          ActiveRecord::Base.establish_connection(config)
          ActiveRecord::Base.connection.recreate_database(config[:database])
        when "postgresql"
          ENV['PGHOST']     = config[:host] if config[:host]
          ENV['PGPORT']     = configs[:port].to_s if config[:port]
          ENV['PGPASSWORD'] = configs[:password].to_s if config[:password]
          enc_option = "-E #{config[:encoding]}" if config[:encoding]
          ActiveRecord::Base.clear_active_connections!
          `dropdb -U "#{config[:username]}" #{config[:database]}`
          `createdb #{enc_option} -U "#{config[:username]}" #{config[:database]}`
        when "sqlite","sqlite3"
          dbfile = config[:database] || config[:dbfile]
          File.delete(dbfile) if File.exist?(dbfile)
        when "sqlserver"
        config  ActiveRecord::Base.establish_connection(:test)
          ActiveRecord::Base.connection.structure_drop.split(";\n\n").each do |ddl|
            ActiveRecord::Base.connection.execute(ddl)
          end
        when "firebird"
          ActiveRecord::Base.establish_connection(:test)
          ActiveRecord::Base.connection.recreate_database!
        else
          raise "Task not supported by '#{config[:adapter]}'"
      end
    end

    desc "Prepare the test database and load the schema"
    task :prepare => ["db:test:clone_structure", "db:test:clone"] do
      if defined?(ActiveRecord::Base) && !ActiveRecord::Base.configurations.blank?
        Rake::Task[{ :sql  => "db:test:clone_structure", :ruby => "db:test:clone" }[ActiveRecord::Base.schema_format]].invoke
      end
    end
  end

  namespace :sessions do
  #  desc "Creates a sessions migration for use with CGI::Session::ActiveRecordStore"
  #  task :create => :environment do
  #    raise "Task unavailable to this database (no migration support)" unless ActiveRecord::Base.connection.supports_migrations?
  #    require 'rails_generator'
  #    require 'rails_generator/scripts/generate'
  #    Rails::Generator::Scripts::Generate.new.run(["session_migration", ENV["MIGRATION"] || "AddSessions"])
  #  end

    desc "Clear the sessions table"
    task :clear => :merb_start do
      session_table = 'session'
      session_table = Inflector.pluralize(session_table) if ActiveRecord::Base.pluralize_table_names
      ActiveRecord::Base.connection.execute "DELETE FROM #{session_table}"
    end
  end
end

def session_table_name
  ActiveRecord::Base.pluralize_table_names ? :sessions : :session
end

def set_firebird_env(config)
  ENV["ISC_USER"]     = config["username"].to_s if config["username"]
  ENV["ISC_PASSWORD"] = config["password"].to_s if config["password"]
end

def firebird_db_string(config)
  FireRuby::Database.db_string_for(config.symbolize_keys)
end
