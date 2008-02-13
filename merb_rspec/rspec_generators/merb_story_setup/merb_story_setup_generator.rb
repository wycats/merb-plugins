class MerbStorySetupGenerator < Merb::GeneratorBase
  
  def initialize(runtime_args, runtime_options = {})
    @base = File.dirname(__FILE__)
    super
  end
  
  def manifest
    record do |m|
      @m = m
      
      @assigns = {}
      
      copy_dirs
      copy_files
      
    end
  end 
  
end