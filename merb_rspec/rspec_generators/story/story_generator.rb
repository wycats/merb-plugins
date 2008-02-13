class StoryGenerator < Merb::GeneratorBase
  
  attr_reader :story_name, :story_path, :step_name, :path_levels, :full_story_path
  
  def initialize(runtime_args, runtime_options = {})
    @base = File.dirname(__FILE__)
    super
    name = runtime_args.shift.split "/"
    @story_name = name.pop
    @story_path = name.empty? ? nil : name.join("/")
    @step_name = @story_path.nil? ? @story_name : (@story_path.gsub("/", "_") + "_" + @story_name)
    @path_levels = @story_path.nil? ? 0 : @story_path.split("/").size
    @full_story_path = @story_path.nil? ? @story_name : File.join(@story_path, @story_name)
  end

  def manifest
    record do |m|
      @m = m
      @assigns = {
                    :story_name       => self.story_name,
                    :story_path       => self.story_path,
                    :step_name        => self.step_name,
                    :path_levels      => self.path_levels,
                    :full_story_path  => self.full_story_path
                  }
                  
      if( !File.exists?('stories/stories/all.rb') ) # So it doesn't get destroyed when you do a destroy script
        m.dependency "merb_story_setup", [""]
      end
      
      m.directory File.join("stories", "stories", self.story_path)
      
      copy_dirs
      copy_files

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
end