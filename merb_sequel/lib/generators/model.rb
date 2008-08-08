Merb::Generators::ModelGenerator.template :model_sequel, :orm => :sequel do
  source(File.dirname(__FILE__), "templates/model/app/models/%file_name%.rb")
  destination("app/models", base_path, "#{file_name}.rb")
end

Merb::Generators::ModelGenerator.invoke :migration, :orm => :sequel do |generator|
  generator.new(destination_root, options.merge(:model => true), file_name, attributes)
end