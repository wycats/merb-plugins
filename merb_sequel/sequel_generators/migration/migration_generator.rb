require 'merb/generators/merb_generator_helpers'

class MigrationGenerator < Merb::GeneratorHelpers::MigrationGeneratorBase
  
  def initialize( *args )
    super( *args )
    @migration_template_name = "new_migration.erb"
  end
  
  def self.superclass
    RubiGen::Base
  end
    
end