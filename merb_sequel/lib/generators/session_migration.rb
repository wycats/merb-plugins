Merb::Generators::SessionMigrationGenerator.template :session_migration_sequel, :orm => :sequel do |t|
  t.source = File.dirname(__FILE__) / 'templates/session_migration/schema/migrations/%version%_sessions.rb'
  t.destination = "schema/migrations/#{version}_sessions.rb"
end