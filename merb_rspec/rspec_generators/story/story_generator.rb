class StoryGenerator < RubiGen::Base
  
  attr_reader :story_name, :story_path, :step_name, :path_levels
  
  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    name = args.shift.split "/"
    @story_name = name.pop
    @story_path = name.empty? ? nil : name.join("/")
    @step_name = @story_path.nil? ? @story_name : (@story_path.gsub("/", "_") + "_" + @story_name)
    @path_levels = @story_path.nil? ? 0 : @story_path.split("/").size
    extract_options
  end

  def manifest
    record do |m|
      m.directory 'stories'
    
      m.template "helper.rb", File.join("stories", "helper.rb")
      
      m.directory 'stories/steps'
      m.directory File.join('stories/stories', "#{@story_path}")
      
      if( !File.exists?('stories/stories/all.rb') ) # So it doesn't get destroyed when you do a destroy script
        m.template 'all.rb', "stories/stories/all.rb"
      end
      m.template 'step.rb',   File.join('stories', 'steps', "#{@step_name}.rb")
      m.template 'story.rb',  File.join('stories/stories', "#{@story_path}", "#{@story_name}.rb")
      m.template 'story',     File.join('stories/stories', "#{@story_path}", "#{@story_name}")
    end
  end

  protected
    def banner
      <<-EOS
Creates a stub for a rSpec text story spec in merb.

USAGE: #{$0} #{spec.name} my_story"

EXAMPLE:
#{$0} #{spec.name} my_story
#{$0} #{spec.name} story_group/specific_story
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