class SequelModelGenerator < RubiGen::Base
  
  default_options :author => nil
  
  attr_reader :name, :model_attributes
  
  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @name = args.shift.snake_case.to_const_string
    extract_options
  end

  def manifest
    unless @name
      puts banner
      exit 1
    end
    record do |m|
      
      # ensure there are no other definitions of this model already defined.
      m.class_collisions(@name)
      # Ensure appropriate folder(s) exists
      m.directory 'app/models'
      # 
      model_filename = @name.snake_case
      spec_filename = @name.snake_case.pluralize
      table_name = spec_filename
      
      
      # Create stubs
      m.template "sequel_model_template.erb", "app/models/#{model_filename}.rb", :assigns => {:class_name => @name}
      
      unless options[:skip_migration]
        m.dependency "sequel_migration",["add_model_#{spec_filename}"], :table_name => table_name, :table_attributes => model_attributes
      end
      
      unless options[:skip_testing]
        m.dependency "sequel_model_test", [@name]
      end
      
      
    end
  end

  protected
    def banner
      <<-EOS
Creates a new model for merb using Sequel

USAGE: #{$0} #{spec.name} NameOfModel [field:type field:type]

Example:
  #{$0} #{spec.name} project

  If you already have 3 migrations, this will create the AddPeople migration in
  schema/migration/004_add_people.rb
  
Options: 
  --skip-migration will not create a migration file



EOS
    end

    def add_options!(opts)
      opts.separator ''
      opts.separator 'Options:'
      # For each option below, place the default
      # at the top of the file next to "default_options"
      # opts.on("-a", "--author=\"Your Name\"", String,
      #         "Some comment about this option",
      #         "Default: none") { |options[:author]| }
      # opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
      opts.on( "--skip-migration", "Don't generate a migration for this model") { |options[:skip_migration]| }
      opts.on( "--skip-testing", "Don't generate a test or spec file for this model") { |options[:skip_testing]| }
      
      
    end
    
    def extract_options
      # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
      # Templates can access these value via the attr_reader-generated methods, but not the
      # raw instance variable value.
      # @author = options[:author]
      
      # get the attributes into a format that can be used.
      attribute = Struct.new(:name, :type)
      @model_attributes = args.map{ |b| b.split(":").size > 1 ? attribute.new(*b.split(":")) : nil }.compact
    end
end