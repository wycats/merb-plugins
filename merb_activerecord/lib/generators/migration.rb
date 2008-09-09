Merb::Generators::MigrationGenerator.template :migration_activerecord, :orm => :activerecord do |t|
  t.source = File.dirname(__FILE__) / 'templates/migration/schema/migrations/%file_name%.rb'
  t.destination = "#{destination_directory}/#{file_name}.rb"
end