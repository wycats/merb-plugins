require 'merb/generators/merb_generator_helpers'

class SequelModelGenerator < Merb::GeneratorHelpers::ModelGeneratorBase
  
  def initialize( *args )
    super( *args )
    @model_template_name = "sequel_model_template.erb"
    @migration_generator_name = "sequel_migration"
    @model_test_generator_name = "merb_model_test"
  end
  
  def self.superclass
    RubiGen::Base
  end
    
end