require 'merb/generators/merb_generator_helpers'

class ModelGenerator < Merb::GeneratorHelpers::ModelGeneratorBase
  
  def initialize( *args )
    super( *args )
    @model_template_name = "new_model.erb"
    @migration_generator_name = "migration"
    @model_test_generator_name = "merb_model_test"
  end
  
  def self.superclass
    RubiGen::Base
  end
    
end