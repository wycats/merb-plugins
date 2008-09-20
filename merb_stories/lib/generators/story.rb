module Merb::Generators

  class StoryGenerator < Generator

    desc <<-DESC
      Generates a plain text story
    DESC

    unless File.exists?('stories/stories/all.rb')
      invoke :merb_story_setup
    end

    first_argument :name, :required => true

    def split_name
      @split_name ||= name.split("/")
    end

    def story_name
      @story_name ||= split_name.pop
    end

    def story_path
      story_name
      @story_path ||= split_name.empty? ? nil : split_name.join("/")
    end

    def step_name
      story_path.nil? ? story_name : (story_path.gsub("/","_") + "_" + story_name)
    end

    def path_levels
      story_path.nil? ? 0 : story_path.split("/").size
    end

    def full_story_path
      story_path.nil? ? story_name : File.join(story_path, story_name)
    end

    def template_dir
      File.join(File.expand_path(File.dirname(__FILE__)), 'templates', 'story')
    end

    template :story do |t|
      t.source = File.join(template_dir, 'story.t')
      t.destination = 'stories/stories/' + full_story_path
    end

    template :story_rb do |t|
      t.source = File.join(template_dir, 'story.rbt')
      t.destination = 'stories/stories/' + full_story_path + '.rb'
    end

    template :step do |t|
      t.source = File.join(template_dir, 'step.rbt')
      t.destination = 'stories/steps/' + step_name + '.rb'
    end
  end

  add :story, StoryGenerator
end
