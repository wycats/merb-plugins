Merb::Generators::ResourceControllerGenerator.template :controller_activerecord, :orm => :activerecord do
  source(File.dirname(__FILE__), "templates/resource_controller/app/controllers/%file_name%.rb")
  destination("app/controllers", base_path, "#{file_name}.rb")
end

[:index, :show, :edit, :new].each do |view|
  Merb::Generators::ResourceControllerGenerator.template "view_#{view}_activerecord".to_sym,
      :orm => :activerecord, :template_engine => :erb do
    source(File.dirname(__FILE__), "templates/resource_controller/app/views/%file_name%/#{view}.html.erb")
    destination("app/views", base_path, "#{file_name}/#{view}.html.erb")
  end
end