Merb::Generators::MigrationGenerator.template :migration_sequel, :orm => :sequel do
  source(File.dirname(__FILE__), 'templates/migration/schema/migrations/%file_name%.rb')
  destination("#{destination_directory}/#{file_name}.rb")
end