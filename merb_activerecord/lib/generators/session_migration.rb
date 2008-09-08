Merb::Generators::SessionMigrationGenerator.template :session_migration_activerecord, :orm => :activerecord do
  source(File.dirname(__FILE__), 'templates/session_migration/schema/migrations/%version%_database_sessions.rb')
  destination("schema/migrations/#{version}_database_sessions.rb")
end