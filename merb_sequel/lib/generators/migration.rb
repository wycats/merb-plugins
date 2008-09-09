Merb::Generators::MigrationGenerator.template :migration_sequel, :orm => :sequel do |t|
  t.source = File.dirname(__FILE__) / 'templates/migration/schema/migrations/%file_name%.rb'
  t.destination = "#{destination_directory}/#{file_name}.rb"
end