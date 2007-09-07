default_yaml = <<-YAML
---
# This is a sample database file for the ActiveRecord ORM
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
  
  Thread.new{ loop{ sleep(60*60); ActiveRecord::Base.verify_active_connections! } }.priority = -10
  
  puts "Connecting to database..."
  ActiveRecord::Base.verification_timeout = 14400
  ActiveRecord::Base.logger = MERB_LOGGER
  ActiveRecord::Base.establish_connection config
else
  # Copy a sample file in and quit
  File.open(MERB_ROOT / "config" / "database.sample.yml", "w") { |file| file.write default_yaml }
  puts "No database.yml file found in config.  Sample file created and copied over so you can edit it."
  exit(1)
end