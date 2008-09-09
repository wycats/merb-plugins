Merb::Generators::SessionMigrationGenerator.template :session_migration_activerecord, :orm => :activerecord do |t|
  t.source = File.dirname(__FILE__) / 'templates/session_migration/schema/migrations/%version%_database_sessions.rb'
  t.destination = "schema/migrations/#{version}_database_sessions.rb"
end