Merb::Generators::ModelGenerator.template :model_activerecord, :orm => :activerecord do |t|
  t.source = File.dirname(__FILE__) / "templates/model/app/models/%file_name%.rb"
  t.destination = "app/models" / base_path / "#{file_name}.rb"
end
    
Merb::Generators::ModelGenerator.invoke :migration, :orm => :activerecord do |generator|
  generator.new(destination_root, options.merge(:model => true), file_name, attributes)
end