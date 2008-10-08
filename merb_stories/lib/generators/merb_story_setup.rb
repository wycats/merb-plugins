module Merb::Generators
  class StorySetupGenerator < Generator

    desc <<-DESC
      Generates setup code for plain text stories
    DESC

    first_argument :ignored

    def self.source_root
      File.join(File.dirname(__FILE__), 'templates', 'merb_story_setup')
    end

    glob!
  end 

  add :merb_story_setup, StorySetupGenerator
end
