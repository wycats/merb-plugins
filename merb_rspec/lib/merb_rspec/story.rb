# http://hassox.blogspot.com/2008/01/merb-supports-rspec-text-stories.html
# based on merb_stories
# Author: Daniel Neighman
# Web:    http://hassox.blogspot.com

module Merb
  module Test
    class RspecStory
      include Merb::Test::ControllerHelper
      include Merb::Test::RouteHelper
      include Merb::Test::ViewHelper
    end
  end
end