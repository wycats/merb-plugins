class SequelMigrationGenerator < RubiGen::Base
  
  default_options :author => nil
  
  attr_reader :name
  
  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @name = args.shift
    options[:table_name] ||= runtime_options[:table_name]
    extract_options
  end

  def manifest
    unless @name
      puts banner
      exit 1
    end
    record do |m|
      # Ensure appropriate folder(s) exists
      m.directory 'schema/migrations'
      
      # Create stubs
      highest_migration = Dir[Dir.pwd+'/schema/migrations/*'].map{|f| File.basename(f) =~ /^(\d+)/; $1}.max
      filename = format("%03d_%s", (highest_migration.to_i+1), @name.snake_case)
      m.template "new_migration.erb", "schema/migrations/#{filename}.rb", 
        :assigns => { :class_name => @name, 
                      :table_name => options[:table_name],
                      :table_attributes => options[:table_attributes] }

    end
  end

  protected
    def banner
      <<-EOS
Creates a new migration for merb using Sequel

USAGE: #{$0} #{spec.name} NameOfMigration [field:type field:type]

Example:
  #{$0} #{spec.name} AddPeople

  If you already have 3 migrations, this will create the AddPeople migration in
  schema/migration/004_add_people.rb
  
  #{$0} #{spec.name} project --table-name projects_table name:string created_at:timestamp
  
  This will create a migration that creates a table call projects_table with these attributes:
    string :name
    timestamp :created_at
    
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
      opts.on( "--table-name=\"table_name_for_migration\"", 
                String,
                "Include a create table with the given table name"){ |options[:table_name]| }
    end
    
    def extract_options
      # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
      # Templates can access these value via the attr_reader-generated methods, but not the
      # raw instance variable value.
      # @author = options[:author]
      if !options[:table_attributes]
        attribute = Struct.new(:name, :type)
        options[:table_attributes] = args.map{ |b| b.split(":").size == 2 ? attribute.new(*b.split(":")) : nil }.compact
      end
    end
end