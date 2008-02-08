class MigrationGenerator < Merb::GeneratorBase
  attr_reader :model_attributes, :model_class_name, :model_file_name, :table_name
  
  def initialize(args, runtime_args = {})
    @base =                 File.dirname(__FILE__)
    super
    @model_file_name  =      args.shift.snake_case
    @table_name       =      @model_file_name.pluralize
    @model_class_name =     @model_file_name.to_const_string
    @model_attributes =     Hash[*(args.map{|a| a.split(":") }.flatten)]
  end
  
  def manifest
    record do |m|
      @m = m
      
      m.directory "schema/migrations"
      
      current_migration_number = Dir[Dir.pwd+'/schema/migrations/*'].map{|f| File.basename(f) =~ /^(\d+)/; $1}.max
      @migration_file_name = format("%03d_%s", (current_migration_number.to_i+1), model_file_name) + "_migration"
    
      @assigns = {  :model_file_name  => model_file_name, 
                    :model_attributes => model_attributes,
                    :model_class_name => model_class_name,
                    :table_name       => table_name,
                    :migration_file_name => @migration_file_name
                  }
      copy_dirs
      copy_files
    end
  end
  
  protected
  def banner
    <<-EOS.split("\n").map{|x| x.strip}.join("\n")
      Creates an Active Record Migration stub..

      USAGE: #{spec.name}"
    EOS
  end
      
end