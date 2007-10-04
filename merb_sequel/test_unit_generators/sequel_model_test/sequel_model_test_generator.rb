class SequelModelTestGenerator < RubiGen::Base
  
  default_options :author => nil
  
  attr_reader :name
  
  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @class_name = args.shift.snake_case.to_const_string
    extract_options
  end

  def manifest
    unless @class_name
      puts banner
      exit 1
    end
    record do |m|
      
      # ensure there are no other definitions of this model already defined.
      # Ensure appropriate folder(s) exists
      m.directory 'test/unit'
      # 
      model_filename = @class_name.snake_case
      
      # Create stubs
      m.template "model_test_unit_template.erb", "test/unit/#{model_filename}_test.rb", :assigns => {:class_name => @class_name}
      
    end
  end

  protected
    def banner
      <<-EOS
Creates a Test::Unit model test for use in Merb

USAGE: #{$0} #{spec.name} NameOfModel
Example:
  #{$0} #{spec.name} project


EOS
    end

    def add_options!(opts)
      # opts.separator ''
      # opts.separator 'Options:'
      # For each option below, place the default
      # at the top of the file next to "default_options"
      # opts.on("-a", "--author=\"Your Name\"", String,
      #         "Some comment about this option",
      #         "Default: none") { |options[:author]| }
      # opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
    end
    
    def extract_options
      # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
      # Templates can access these value via the attr_reader-generated methods, but not the
      # raw instance variable value.
      # @author = options[:author]
    end
end