default_yaml = <<-YAML
---
# This is a sample database file for the Sequel ORM
:development: &defaults
  :adapter: mysql
  :database: sample_development
  :username: teh_user
  :password: secrets
  :host: localhost
  :socket: /tmp/mysql.sock

:test:
  <<: *defaults
  :database: sample_test

:production:
  <<: *defaults
  :database: sample_production
YAML

config_file = MERB_ROOT / "config" / "database.yml"

if File.exists? config_file
  # Convert string keys to symbols
  full_config = Erubis.load_yaml_file(config_file)
  config = (Merb::Plugins.config[:merb_sequel] = {})
  (full_config[MERB_ENV.to_sym] || full_config[MERB_ENV]).each { |k, v| config[k.to_sym] = v }
  
  puts "Connecting to database..."
  
  # Load the correct Sequel adapter and set it up according to the yaml file
  case config[:adapter]
  when 'mysql'
    require "sequel/mysql"
    host = config[:host] || 'localhost'
    user = config[:user] || config[:username] || 'root'
    password = config[:password]
    # Use Sequel::Model.db to access this object
    Sequel.mysql(config[:database], :host => host, :user => user, :password => password, :logger => MERB_LOGGER)
  when 'sqlite'
    require "sequel/sqlite"
    if config[:database]
      Sequel.sqlite config[:database]
    else
      Sequel.sqlite
    end
  else
    require "sequel/sqlite"
    p full_config
    p config
    puts "No adapter specified in config/database.yml... trying a memory-only sqlite database"
    Sequel.sqlite
  end
  
else
  # Copy a sample file in and quit
  sample_file = MERB_ROOT / "config" / "database.sample.yml"
  File.open(sample_file, "w") { |file| file.write default_yaml } unless File.exists?(sample_file)
  puts "No database.yml file found in config.  Sample file created and copied over so you can edit it."
  exit(1)
end