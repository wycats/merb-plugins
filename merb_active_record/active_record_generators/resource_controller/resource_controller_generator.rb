require 'merb/generators/merb_generator_helpers'

class ResourceControllerGenerator < Merb::GeneratorHelpers::ControllerGeneratorBase

  def initialize(*args)
    runtime_options = args.last.is_a?(Hash) ? args.pop : {}
    name, *actions = args.flatten
    runtime_options[:actions] = %w[index show new edit]
    runtime_options[:test_stub_generator] = "merb_controller_test"
    super( [name], runtime_options )
  end

  def self.superclass
    RubiGen::Base
  end
  
  protected
  def banner
        <<-EOS
  Creates a Merb controller, views and specs using Active Record Models

  USAGE: #{$0} #{spec.name} resource_name"
  EOS
  end
  
end